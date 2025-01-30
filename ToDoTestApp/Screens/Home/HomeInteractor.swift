//
//  HomeInteractor.swift
//  ToDoTestApp
//
//  Created by Muhammadjon Madaminov on 30/01/25.
//

import UIKit

protocol HomeInteractorInputProtocol: AnyObject {
    func fetchRemoteTasks()
    func saveTask(_ task: TaskModel)
    func deleteTask(_ task: TaskModel)
    func filterTasks(by text: String)
    func loadTasks()
    func handleTaskUpdate(_ task: TaskModel)
    func setTaskDetails(_ tasks: [TaskModel]) -> [TaskModel]
    func getTasks()
    func getItemFromIndexPath(_ indexPath: IndexPath) -> TaskModel
}

protocol HomeInteractorOutputProtocol: AnyObject {
    func tasksFetched(_ tasks: [TaskModel])
    func tasksFetchFailed(_ error: Error)
    func tasksFiltered(_ tasks: [TaskModel])
}



class HomeInteractor: HomeInteractorInputProtocol {
    weak var output: HomeInteractorOutputProtocol!
    var coreDataManager: CoreDataManageable
    var networkManager: NetworkManagerProtocol
    var userDefaults: UserDefaults
    
    private var allTasks: [TaskModel] = []
    
    init(coreDataManager: CoreDataManageable = CoreDataManager(configuration: .production), networkManager: NetworkManagerProtocol = NetworkManager(), userDefaults: UserDefaults = UserDefaults()) {
        self.coreDataManager = coreDataManager
        self.networkManager = networkManager
        self.userDefaults = userDefaults
    }
    
    func getTasks() {
        output.tasksFetched(allTasks)
    }
    
    func getItemFromIndexPath(_ indexPath: IndexPath) -> TaskModel {
        return allTasks[indexPath.row]
    }
    
    func loadTasks() {
        let userDefaultsValue = "FirstTimeFetching"
        let savedTasks = coreDataManager.fetchTasks()
        
        if userDefaults.bool(forKey: userDefaultsValue) {
            allTasks = savedTasks.sorted(by: { $0.createdAt ?? .now > $1.createdAt ?? .now })
            output.tasksFetched(allTasks)
        } else {
            userDefaults.set(true, forKey: userDefaultsValue)
            fetchRemoteTasks()
        }
    }
    
    internal func fetchRemoteTasks() {
        networkManager.fetchData(for: .todos, type: TaskResponse.self) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                let processedTasks = self.setTaskDetails(response.todos)
                DispatchQueue.main.async {
                    processedTasks.forEach { self.coreDataManager.saveTask($0) }
                    self.allTasks = processedTasks.sorted(by: { $0.createdAt ?? .now > $1.createdAt ?? .now })
                    self.output.tasksFetched(self.allTasks)
                }
                
            case .failure(let error):
                self.output.tasksFetchFailed(error)
            }
        }
    }
    
    func filterTasks(by text: String) {
        let filtered = text.isEmpty ? allTasks : allTasks.filter { $0.todo.lowercased().contains(text.lowercased()) }
        output.tasksFiltered(filtered)
    }
    
    func saveTask(_ task: TaskModel) {
        self.coreDataManager.saveTask(task)
        allTasks.insert(task, at: 0)
    }
    
    func handleTaskUpdate(_ task: TaskModel) {
        if let index = allTasks.firstIndex(where: { $0.id == task.id }) {
            coreDataManager.updateTask(task)
            allTasks[index] = task
        } else {
            coreDataManager.saveTask(task)
            allTasks.insert(task, at: 0)
        }
        output.tasksFetched(allTasks)
    }
    
    func deleteTask(_ task: TaskModel) {
        coreDataManager.deleteTask(task)
        allTasks.removeAll { $0.id == task.id }
        output.tasksFetched(allTasks)
    }
    
    internal func setTaskDetails(_ tasks: [TaskModel]) -> [TaskModel] {
        tasks.map {
            var task = $0
            task.createdAt = Date()
            task.description = task.todo
            return task
        }
    }
}
