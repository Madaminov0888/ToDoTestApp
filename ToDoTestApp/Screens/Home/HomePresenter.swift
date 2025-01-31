//
//  HomePresenter.swift
//  ToDoTestApp
//
//  Created by Muhammadjon Madaminov on 30/01/25.
//

import UIKit

protocol HomePresenterProtocol: AnyObject {
    func viewDidLoad()
    func didSelectAddTask()
    func didUpdateSearchQuery(_ query: String)
    func didUpdateTask(_ task: TaskModel)
    func didDeleteTask(_ task: TaskModel)
    func didSelectEditTask(_ task: TaskModel)
    func didGetItemFromIndexPath(_ indexPath: IndexPath) -> TaskModel
    func didGetTasks()
}


class HomePresenter: HomePresenterProtocol, HomeInteractorOutputProtocol {
    
    weak var view: HomeViewProtocol?
    var interactor: HomeInteractorInputProtocol!
    var router: HomeRouterProtocol!
    
    func viewDidLoad() {
        interactor.loadTasks()
    }
    
    func didSelectAddTask() {
        router.navigateToEditTask(onSave: editTasksDismissed())
    }
    
    func didSelectEditTask(_ task: TaskModel) {
        router.navigateToEditTask(task, onSave: editTasksDismissed())
    }
    
    func didUpdateSearchQuery(_ query: String) {
        interactor.filterTasks(by: query)
    }
    
    func didUpdateTask(_ task: TaskModel) {
        interactor.handleTaskUpdate(task)
    }
    
    func didDeleteTask(_ task: TaskModel) {
        interactor.deleteTask(task)
    }
    
    func didGetItemFromIndexPath(_ indexPath: IndexPath) -> TaskModel {
        return interactor.getItemFromIndexPath(indexPath)
    }
    
    func editTasksDismissed() -> (_ task:TaskModel) -> Void {
        return { [weak self] task in
            guard let self = self else { return }
            didUpdateTask(task)
        }
    }
    
    
    func didGetTasks() {
        interactor.getTasks()
    }
    
    // MARK: - HomeInteractorOutputProtocol
    
    func tasksFetched(_ tasks: [TaskModel]) {
        view?.showTasks(tasks)
        view?.updateTaskCount(tasks.count)
    }
    
    func tasksFetchFailed(_ error: Error) {
        //Can be used system Alerts
        print(error.localizedDescription)
    }
    
    func tasksFiltered(_ tasks: [TaskModel]) {
        view?.showTasks(tasks)
    }
}
