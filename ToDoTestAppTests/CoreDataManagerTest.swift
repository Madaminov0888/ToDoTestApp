//
//  CoreDataManagerTest.swift
//  ToDoTestAppTests
//
//  Created by Muhammadjon Madaminov on 31/01/25.
//

import UIKit
import CoreData
import XCTest
@testable import ToDoTestApp


class CoreDataManagerTests: XCTestCase {
    var coreDataManager: CoreDataManager!

    override func setUp() {
        super.setUp()
        coreDataManager = CoreDataManager(configuration: .testing)
    }

    override func tearDown() {
        coreDataManager = nil
        super.tearDown()
    }

    func testSaveTask() {
        // Given
        let task = TaskModel(id: 1, todo: "Test Task", completed: false, userId: 1)

        // When
        coreDataManager.saveTask(task)
        let tasks = coreDataManager.fetchTasks()

        // Then
        XCTAssertEqual(tasks.count, 1, "Should store one task in Core Data")
        XCTAssertEqual(tasks.first?.todo, "Test Task", "Task todo should match")
    }

    func testFetchTasks() {
        // Given
        let task1 = TaskModel(id: 1, todo: "Task 1", completed: false, userId: 1)
        let task2 = TaskModel(id: 2, todo: "Task 2", completed: false, userId: 1)
        coreDataManager.saveTask(task1)
        coreDataManager.saveTask(task2)

        // When
        let tasks = coreDataManager.fetchTasks()

        // Then
        XCTAssertEqual(tasks.count, 2, "Should fetch 2 tasks")
    }

    func testUpdateTask() {
        // Given
        let task = TaskModel(id: 1, todo: "Old Task", completed: false, userId: 1)
        coreDataManager.saveTask(task)
        var updatedTask = task
        updatedTask.todo = "Updated Task"
        updatedTask.completed = true

        // When
        coreDataManager.updateTask(updatedTask)
        let tasks = coreDataManager.fetchTasks()

        // Then
        XCTAssertEqual(tasks.count, 1, "Should still have 1 task")
        XCTAssertEqual(tasks.first?.todo, "Updated Task", "Task todo should be updated")
        XCTAssertTrue(tasks.first!.completed, "Task should be marked as completed")
    }

    func testDeleteTask() {
        // Given
        let task = TaskModel(id: 1, todo: "Task to delete", completed: false, userId: 1)
        coreDataManager.saveTask(task)

        // When
        coreDataManager.deleteTask(task)
        let tasks = coreDataManager.fetchTasks()

        // Then
        XCTAssertEqual(tasks.count, 0, "Should remove task from Core Data")
    }
}
