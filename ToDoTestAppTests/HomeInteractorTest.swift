//
//  HomeInteractorTest.swift
//  ToDoTestAppTests
//
//  Created by Muhammadjon Madaminov on 31/01/25.
//


import XCTest
@testable import ToDoTestApp


// MARK: - Mock Network Manager
class MockNetworkManager: NetworkManagerProtocol {
    var fetchDataCalled = false
    var stubbedResult: Any?

    func fetchData<T: Codable>(for endpoint: EndpointProtocol, type: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        fetchDataCalled = true
        if let result = stubbedResult as? Result<T, Error> {
            completion(result)
        } else {
            print("It is not working – Type mismatch:", stubbedResult as Any)
        }
    }
}

// MARK: - Mock Core Data Manager
class MockCoreDataManager: CoreDataManageable {
    var savedTasks: [TaskModel] = []
    var fetchTasksCalled = false
    var saveTaskCalled = false
    var deleteTaskCalled = false
    var updateTaskCalled = false

    func fetchTasks() -> [TaskModel] {
        fetchTasksCalled = true
        return savedTasks
    }

    func saveTask(_ task: TaskModel) {
        saveTaskCalled = true
        savedTasks.append(task)
    }

    func deleteTask(_ task: TaskModel) {
        deleteTaskCalled = true
        savedTasks.removeAll { $0.id == task.id }
    }
    
    func saveContext() {
        print("Saves context")
    }

    func updateTask(_ task: TaskModel) {
        updateTaskCalled = true
        if let index = savedTasks.firstIndex(where: { $0.id == task.id }) {
            savedTasks[index] = task
        }
    }
}

// MARK: - Mock Home Interactor Output
class MockHomeInteractorOutput: HomeInteractorOutputProtocol {
    var receivedTasks: [TaskModel]?
    var filteredTasks: [TaskModel]?
    var receivedError: Error?
    var tasksFetchedExpectation: XCTestExpectation?
    var tasksFetchFailedExpectation: XCTestExpectation?

    func tasksFetched(_ tasks: [TaskModel]) {
        receivedTasks = tasks
        tasksFetchedExpectation?.fulfill()
    }
    
    func tasksFetchFailed(_ error: Error) {
        receivedError = error
        tasksFetchFailedExpectation?.fulfill()
    }
    
    func tasksFiltered(_ tasks: [TaskModel]) {
        filteredTasks = tasks
    }
}



// MARK: - HomeInteractor Unit Tests
class HomeInteractorTests: XCTestCase {
    var sut: HomeInteractor!
    var mockOutput: MockHomeInteractorOutput!
    var mockCoreData: MockCoreDataManager!
    var mockNetwork: MockNetworkManager!
    var mockUserDefaults: UserDefaults!

    override func setUp() {
        super.setUp()
        mockOutput = MockHomeInteractorOutput()
        mockCoreData = MockCoreDataManager()
        mockNetwork = MockNetworkManager()
        mockUserDefaults = UserDefaults()

        sut = HomeInteractor(
            coreDataManager: mockCoreData,
            networkManager: mockNetwork,
            userDefaults: mockUserDefaults
        )
        sut.output = mockOutput
    }

    override func tearDown() {
        sut = nil
        mockOutput = nil
        mockCoreData = nil
        mockNetwork = nil
        mockUserDefaults = nil
        super.tearDown()
    }


    func testGetTasks() {
        // Given
        let tasks = [TaskModel(id: 1, todo: "Test Task", completed: false, userId: 1)]
        sut.allTasks = tasks

        // When
        sut.getTasks()

        // Then
        XCTAssertEqual(mockOutput.receivedTasks?.count, 1, "Should return the correct number of tasks")
    }

    func testGetItemFromIndexPath() {
        // Given
        let task = TaskModel(id: 1, todo: "Task", completed: false, userId: 1)
        sut.allTasks = [task]

        // When
        let result = sut.getItemFromIndexPath(IndexPath(row: 0, section: 0))

        // Then
        XCTAssertEqual(result.id, task.id, "Should return the correct task")
    }

    func testLoadTasks_UsesLocalDataIfAvailable() {
        // Given
        mockCoreData.savedTasks = [
            TaskModel(id: 1, todo: "Saved Task", completed: false, userId: 1)
        ]
        mockUserDefaults.set(true, forKey: "FirstTimeFetching")

        // When
        sut.loadTasks()

        // Then
        XCTAssertTrue(mockCoreData.fetchTasksCalled, "Should fetch tasks from Core Data")
        XCTAssertEqual(mockOutput.receivedTasks?.count, 1, "Should load tasks from Core Data")
    }

    
    func testLoadTasks_FirstTimeFetchingFromNetwork() {
        // Given
        mockUserDefaults.set(false, forKey: "FirstTimeFetching")
        let mockTasks = [TaskModel(id: 1, todo: "Fetched Task", completed: false, userId: 1)]
//        mockNetwork.stubbedResult = .success(TaskResponse(todos: mockTasks))
        mockNetwork.stubbedResult = Result<[TaskModel], Error>.success(mockTasks)

        // When
        sut.loadTasks()

        // Then
        XCTAssertTrue(mockNetwork.fetchDataCalled, "Should fetch data from network on first load")
    }

    
    
    func testFetchRemoteTasks_Success() {
        // Given
        let mockTasks = [TaskModel(id: 1, todo: "Fetched Task", completed: false, userId: 1)]
        let mockResponse = TaskResponse(todos: mockTasks)
        mockNetwork.stubbedResult = Result<TaskResponse, Error>.success(mockResponse) // Explicit type

        let expectation = self.expectation(description: "Tasks fetched")
        mockOutput.tasksFetchedExpectation = expectation
        
        // When
        sut.fetchRemoteTasks()
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(mockNetwork.fetchDataCalled)
        XCTAssertEqual(mockOutput.receivedTasks?.count, 1, "Should receive one task")
        XCTAssertEqual(mockCoreData.savedTasks.count, 1, "Should save one task in CoreData")
    }
    
    func testFetchRemoteTasks_Failure() {
        // Given
        let error = NSError(domain: "NetworkError", code: -1, userInfo: nil)
        mockNetwork.stubbedResult = Result<TaskResponse, Error>.failure(error)
        let expectation = self.expectation(description: "Tasks fetch failed")
        mockOutput.tasksFetchFailedExpectation = expectation
        
        // When
        sut.fetchRemoteTasks()
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertNotNil(mockOutput.receivedError)
        XCTAssertTrue(mockCoreData.savedTasks.isEmpty)
    }
    
    
    func testFilterTasks() {
        // Given
        sut.allTasks = [
            TaskModel(id: 1, todo: "Buy milk", completed: false, userId: 1),
            TaskModel(id: 2, todo: "Clean room", completed: false, userId: 1)
        ]

        // When
        sut.filterTasks(by: "clean")

        // Then
        XCTAssertEqual(mockOutput.filteredTasks?.count, 1, "Should correctly filter tasks")
    }

    func testSaveTask() {
        // Given
        let task = TaskModel(id: 1, todo: "New Task", completed: false, userId: 1)

        // When
        sut.saveTask(task)

        // Then
        XCTAssertTrue(mockCoreData.saveTaskCalled, "Should call saveTask on Core Data")
        XCTAssertEqual(sut.allTasks.count, 1, "Should add task to allTasks array")
    }

    func testHandleTaskUpdate_ExistingTask() {
        // Given
        let task = TaskModel(id: 1, todo: "Original", completed: false, userId: 1)
        sut.allTasks = [task]
        let updatedTask = TaskModel(id: 1, todo: "Updated", completed: true, userId: 1)

        // When
        sut.handleTaskUpdate(updatedTask)

        // Then
        XCTAssertTrue(mockCoreData.updateTaskCalled, "Should call updateTask on Core Data")
        XCTAssertEqual(sut.allTasks.first?.todo, "Updated", "Should update task in allTasks")
    }

    func testHandleTaskUpdate_NewTask() {
        // Given
        let newTask = TaskModel(id: 2, todo: "New Task", completed: false, userId: 1)

        // When
        sut.handleTaskUpdate(newTask)

        // Then
        XCTAssertTrue(mockCoreData.saveTaskCalled, "Should save new task")
        XCTAssertEqual(sut.allTasks.count, 1, "Should add new task to allTasks")
    }

    func testDeleteTask() {
        // Given
        let task = TaskModel(id: 1, todo: "Task to delete", completed: false, userId: 1)
        sut.allTasks = [task]

        // When
        sut.deleteTask(task)

        // Then
        XCTAssertTrue(mockCoreData.deleteTaskCalled, "Should call deleteTask on Core Data")
        XCTAssertEqual(sut.allTasks.count, 0, "Should remove task from allTasks")
    }
}
