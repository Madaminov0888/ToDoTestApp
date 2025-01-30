//
//  CoreDataManager.swift
//  ToDoTestApp
//
//  Created by Muhammadjon Madaminov on 29/01/25.
//


import CoreData
import UIKit


protocol CoreDataManageable {
    func saveTask(_ task: TaskModel)
    func fetchTasks() -> [TaskModel]
    func deleteTask(_ task: TaskModel)
    func updateTask(_ task: TaskModel)
    func saveContext()
}

enum CoreDataConfiguration {
    case production
    case testing
}

class CoreDataManager: CoreDataManageable {
    
    private let persistentContainer: NSPersistentContainer
    private let configuration: CoreDataConfiguration
    
    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    init(configuration: CoreDataConfiguration = .production) {
        self.configuration = configuration
        self.persistentContainer = NSPersistentContainer(name: "Tasks")
        
        configureContainer()
    }
    
    private func configureContainer() {
        if configuration == .testing {
            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            persistentContainer.persistentStoreDescriptions = [description]
        }
        
        persistentContainer.loadPersistentStores { [weak self] (storeDescription, error) in
            if let error = error {
                fatalError("Core Data stack initialization failed: \(error.localizedDescription)")
            }
            
            if self?.configuration == .testing {
                self?.persistentContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            }
        }
    }
    
    
    func saveTask(_ task: TaskModel) {
        let fetchRequest: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", "\(task.id)")
        
        do {
            let existingTasks = try viewContext.fetch(fetchRequest)
            if !existingTasks.isEmpty { return }
        } catch {
            print("Error checking existing tasks: \(error.localizedDescription)")
            return
        }
        
        let newTask = TaskEntity(context: viewContext)
        newTask.id = "\(task.id)"
        newTask.todo = task.todo
        newTask.taskDescription = task.description
        newTask.completed = task.completed
        newTask.createdAt = task.createdAt
        
        saveContext()
    }
    
    func fetchTasks() -> [TaskModel] {
        let fetchRequest: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        
        do {
            let results = try viewContext.fetch(fetchRequest)
            return results.compactMap { entity in
                guard let idString = entity.id,
                      let id = Int(idString) else { return nil }
                
                return TaskModel(
                    id: id,
                    todo: entity.todo ?? "",
                    description: entity.taskDescription,
                    createdAt: entity.createdAt,
                    completed: entity.completed,
                    userId: 0
                )
            }
        } catch {
            print("Error fetching tasks: \(error.localizedDescription)")
            return []
        }
    }
    
    
    func updateTask(_ task: TaskModel) {
        let fetchRequest: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", String(task.id))
        
        do {
            let results = try viewContext.fetch(fetchRequest)
            
            guard let entity = results.first else {
                return
            }
            
            if entity.completed != task.completed {
                entity.completed = task.completed
            }
            
            if entity.todo != task.todo {
                entity.todo = task.todo
            }
            
            if entity.description != task.description, let description = task.description {
                entity.taskDescription = description
            }
            
            if entity.createdAt != task.createdAt {
                entity.createdAt = task.createdAt
            }
            
            saveContext()
        } catch {
            print("Update error: \(error.localizedDescription)")
        }
    }
    
    
    func deleteTask(_ task: TaskModel) {
        let fetchRequest: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", "\(task.id)")
        
        do {
            let results = try viewContext.fetch(fetchRequest)
            results.forEach({ viewContext.delete($0) })
            saveContext()
        } catch {
            print("")
        }
    }
    
    func saveContext() {
        guard viewContext.hasChanges else { return }
        
        do {
            try viewContext.save()
        } catch {
            print("Error saving context: \(error.localizedDescription)")
            viewContext.rollback()
        }
    }
}
