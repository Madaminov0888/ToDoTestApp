//
//  HomePresenterTest.swift
//  ToDoTestAppTests
//
//  Created by Muhammadjon Madaminov on 31/01/25.
//

import UIKit
import XCTest
@testable import ToDoTestApp


class MockHomeView: HomeViewProtocol {
    var showTasksCalled = false
    var updateTaskCountCalled = false
    var loadedTasks: [TaskModel] = []
    var updatedTaskCount: Int = 0
    
    func showTasks(_ tasks: [TaskModel]) {
        self.showTasksCalled = true
        loadedTasks = tasks
    }
    
    func updateTaskCount(_ count: Int) {
        self.updateTaskCountCalled = true
        updatedTaskCount = count
    }
}


class MockHomeRouter: HomeRouterProtocol {
    var navigateToAddTaskCalled = false
    var navigateToEditTaskCalled = false
    
    func navigateToEditTask(onSave: @escaping (ToDoTestApp.TaskModel) -> Void) {
        self.navigateToAddTaskCalled = true
    }
    
    func navigateToEditTask(_ task: ToDoTestApp.TaskModel, onSave: @escaping (ToDoTestApp.TaskModel) -> Void) {
        self.navigateToEditTaskCalled = true
    }
}


class MockHomeInteractor: HomeInteractorInputProtocol {
    var fetchTasksCalled = false
    var deleteTaskCalled = false
    var updateTaskCalled = false
    var addTaskCalled = false
    var loadTasksCalled = false
    var filterTasksCalled = false
    var handleTaskUpdateCalled = false
    var getItemFromIndexPathCalled = false
    var getTasksCalled = false
    
    var fetchedTasks: [TaskModel] = []
    var deletedTask: TaskModel?
    var updatedTask: TaskModel?
    var addedTask: TaskModel?
    var filterQuery: String?
    var indexPathForItem: IndexPath?
    
    func fetchRemoteTasks() {
        self.fetchTasksCalled = true
    }
    
    func saveTask(_ task: ToDoTestApp.TaskModel) { }
    
    func deleteTask(_ task: ToDoTestApp.TaskModel) {
        deleteTaskCalled = true
        deletedTask = task
    }
    
    func filterTasks(by text: String) {
        filterTasksCalled = true
        filterQuery = text
    }
    
    func loadTasks() {
        self.loadTasksCalled = true
    }
    
    func handleTaskUpdate(_ task: ToDoTestApp.TaskModel) {
        handleTaskUpdateCalled = true
        updatedTask = task
    }
    
    func setTaskDetails(_ tasks: [ToDoTestApp.TaskModel]) -> [ToDoTestApp.TaskModel] {
        return tasks
    }
    
    func getTasks() {
        getTasksCalled = true
    }
    
    func getItemFromIndexPath(_ indexPath: IndexPath) -> ToDoTestApp.TaskModel {
        getItemFromIndexPathCalled = true
        indexPathForItem = indexPath
        return TaskModel(id: 1, todo: "Test", description: "Test", completed: Bool.random(), userId: 238)
    }
}



final class HomePresenterTest: XCTestCase {
    var sut: HomePresenter!
    var mockHomeView: MockHomeView!
    var mockHomeRouter: MockHomeRouter!
    var mockHomeInteractor: MockHomeInteractor!
    
    override func setUp() {
        super.setUp()
        mockHomeView = MockHomeView()
        mockHomeRouter = MockHomeRouter()
        mockHomeInteractor = MockHomeInteractor()
        sut = HomePresenter()
        sut.view = mockHomeView
        sut.router = mockHomeRouter
        sut.interactor = mockHomeInteractor
    }
    
    override func tearDown() {
        sut = nil
        mockHomeView = nil
        mockHomeRouter = nil
        mockHomeInteractor = nil
        super.tearDown()
    }
    
    // MARK: - Test Cases
    
    func testViewDidLoad_CallsInteractorLoadTasks() {
        // When
        sut.viewDidLoad()
        
        // Then
        XCTAssertTrue(mockHomeInteractor.loadTasksCalled)
    }
    
    func testDidSelectAddTask_CallsRouter() {
        // When
        sut.didSelectAddTask()
        
        // Then
        XCTAssertTrue(mockHomeRouter.navigateToAddTaskCalled)
    }
    
    func testDidSelectEditTask_CallsRouter() {
        // Given
        let task = TaskModel(id: 1, todo: "Test", description: "Test", completed: Bool.random(), userId: 238)
        
        // When
        sut.didSelectEditTask(task)
        
        // Then
        XCTAssertTrue(mockHomeRouter.navigateToEditTaskCalled)
    }
    
    func testDidUpdateSearchQuery_CallsInteractor() {
        // Given
        let query = "test"
        
        // When
        sut.didUpdateSearchQuery(query)
        
        // Then
        XCTAssertTrue(mockHomeInteractor.filterTasksCalled)
        XCTAssertEqual(mockHomeInteractor.filterQuery, query)
    }
    
    func testDidUpdateTask_CallsInteractor() {
        // Given
        let task = TaskModel(id: 1, todo: "Test", description: "Test", completed: Bool.random(), userId: 238)
        
        // When
        sut.didUpdateTask(task)
        
        // Then
        XCTAssertTrue(mockHomeInteractor.handleTaskUpdateCalled)
        XCTAssertEqual(mockHomeInteractor.updatedTask, task)
    }
    
    func testDidDeleteTask_CallsInteractor() {
        // Given
        let task = TaskModel(id: 1, todo: "Test", description: "Test", completed: Bool.random(), userId: 238)
        
        // When
        sut.didDeleteTask(task)
        
        // Then
        XCTAssertTrue(mockHomeInteractor.deleteTaskCalled)
        XCTAssertEqual(mockHomeInteractor.deletedTask, task)
    }
    
    
    func testDidGetItemFromIndexPath_CallsInteractor() {
        // Given
        let indexPath = IndexPath(row: 0, section: 0)
        
        // When
        let task = sut.didGetItemFromIndexPath(indexPath)
        
        // Then
        XCTAssertTrue(mockHomeInteractor.getItemFromIndexPathCalled)
        XCTAssertEqual(mockHomeInteractor.indexPathForItem, indexPath)
        XCTAssertEqual(task.id, 1)
    }
    
    func testEditTasksDismissed_UpdatesTask() {
        // Given
        let task = TaskModel(id: 1, todo: "Test", description: "Test", completed: Bool.random(), userId: 238)
        
        // When
        let onSave = sut.editTasksDismissed()
        onSave(task)
        
        // Then
        XCTAssertTrue(mockHomeInteractor.handleTaskUpdateCalled)
        XCTAssertEqual(mockHomeInteractor.updatedTask, task)
    }
    
    func testTasksFetched_UpdatesView() {
        // Given
        let tasks = [TaskModel(id: 1, todo: "Test", description: "Test", completed: Bool.random(), userId: 238)]
        
        // When
        sut.tasksFetched(tasks)
        
        // Then
        XCTAssertTrue(mockHomeView.showTasksCalled)
        XCTAssertEqual(mockHomeView.loadedTasks, tasks)
        XCTAssertTrue(mockHomeView.updateTaskCountCalled)
        XCTAssertEqual(mockHomeView.updatedTaskCount, tasks.count)
    }
    
    func testTasksFiltered_UpdatesView() {
        // Given
        let tasks = [TaskModel(id: 1, todo: "Test", description: "Test", completed: Bool.random(), userId: 238)]
        
        // When
        sut.tasksFiltered(tasks)
        
        // Then
        XCTAssertTrue(mockHomeView.showTasksCalled)
        XCTAssertEqual(mockHomeView.loadedTasks, tasks)
    }
    
    func testDidGetTasks_CallsInteractor() {
        // When
        sut.didGetTasks()
        
        // Then
        XCTAssertTrue(mockHomeInteractor.getTasksCalled)
    }
}

