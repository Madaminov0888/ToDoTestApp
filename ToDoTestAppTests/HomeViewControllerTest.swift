//
//  HomeViewControllerTest.swift
//  ToDoTestAppTests
//
//  Created by Muhammadjon Madaminov on 31/01/25.
//

import XCTest
@testable import ToDoTestApp



// MARK: - Mock Presenter
class MockHomePresenter: HomePresenterProtocol {
    var viewDidLoadCalled = false
    var didSelectAddTaskCalled = false
    var receivedSearchQuery: String?
    var stubbedTask = TaskModel(id: 0, todo: "", completed: false, userId: 0)
    
    func viewDidLoad() { viewDidLoadCalled = true }
    func didSelectAddTask() { didSelectAddTaskCalled = true }
    func didUpdateSearchQuery(_ query: String) { receivedSearchQuery = query }
    func didUpdateTask(_ task: TaskModel) {}
    func didDeleteTask(_ task: TaskModel) {}
    func didSelectEditTask(_ task: TaskModel) {}
    func didGetItemFromIndexPath(_ indexPath: IndexPath) -> TaskModel { stubbedTask }
    func didGetTasks() {}
}




class HomeViewControllerTests: XCTestCase {
    var sut: HomeViewController!
    var mockPresenter: MockHomePresenter!
    
    override func setUp() {
        super.setUp()
        sut = HomeViewController()
        mockPresenter = MockHomePresenter()
        sut.presenter = mockPresenter
        
        // Load view hierarchy
        sut.loadViewIfNeeded()
    }
    
    override func tearDown() {
        sut = nil
        mockPresenter = nil
        super.tearDown()
    }
    
    
    func testViewDidLoad() {
        // When
        sut.viewDidLoad()
        
        // Then
        XCTAssertTrue(mockPresenter.viewDidLoadCalled, "Presenter's viewDidLoad should be called")
        XCTAssertNotNil(sut.tableView, "TableView should be initialized")
        XCTAssertNotNil(sut.dataSource, "DataSource should be initialized")
        XCTAssertEqual(sut.title, "Задачи", "Title should be set correctly")
    }
    
    func testShowTasksUpdatesDataSource() {
        // Given
        let testTasks = [
            TaskModel(id: 1, todo: "Test 1", completed: false, userId: 1),
            TaskModel(id: 2, todo: "Test 2", completed: true, userId: 1)
        ]
        
        // When
        sut.showTasks(testTasks)
        
        // Then
        let snapshot = sut.dataSource?.snapshot()
        XCTAssertEqual(snapshot?.numberOfItems, 2, "Should display 2 tasks")
    }
    
    func testUpdateTaskCountUpdatesToolbar() {
        // When
        let num = 5
        sut.updateTaskCount(num)
        
        // Then
        XCTAssertEqual(sut.toolbarItems?.count, 4, "Should have 4 toolbar items")
        if let labelItem = sut.toolbarItems?[1].customView as? UILabel {
            XCTAssertEqual(labelItem.text, "\(num) Задач", "Task count should be formatted correctly")
        } else {
            XCTFail("Task count label not found")
        }
    }
    
    
    func testSearchBarUpdatesPresenter() {
        // Given
        let searchController = sut.navigationItem.searchController!
        let searchBar = searchController.searchBar
        
        // When
        searchBar.text = "test"
        sut.updateSearchResults(for: searchController)
        
        // Then
        XCTAssertEqual(mockPresenter.receivedSearchQuery, "test", "Should forward search query to presenter")
    }
    
    func testAddButtonAction() {
        // When
        sut.newTaskTapped()
        
        // Then
        XCTAssertTrue(mockPresenter.didSelectAddTaskCalled, "Add task should be triggered")
    }
    
    func testBlurEffectManagement() {
        // When
        sut.applyBlurEffect()
        
        // Then
        XCTAssertNotNil(sut.view.subviews.first { $0.tag == 999 }, "Blur view should be added")
        
        // When
        sut.removeBlurEffect()
        
        // Then
        XCTAssertNil(sut.view.subviews.first { $0.tag == 999 }, "Blur view should be removed")
    }
    
    
    //MARK: Performance testing
    func testViewDidLoadPerformance() {
        measure {
            sut.viewDidLoad()
        }
    }
    
    
    func testShowTasksPerformance() {
        let testTasks = (1...10000).map { TaskModel(id: $0, todo: "Task \($0)", completed: Bool.random(), userId: 1) }
        
        measure {
            sut.showTasks(testTasks)
        }
    }
    
    
    func testUpdateTaskCountPerformance() {
        measure {
            sut.updateTaskCount(10000)
        }
    }
    
    
    func testSearchPerformance() {
        let searchController = sut.navigationItem.searchController!
        let searchBar = searchController.searchBar
        let query = "test"

        measure {
            searchBar.text = query
            sut.updateSearchResults(for: searchController)
        }
    }
    
    
    
    func testContextMenuPerformance() {
        let indexPath = IndexPath(row: 0, section: 0)
        
        measure {
            _ = sut.tableView(sut.tableView!, contextMenuConfigurationForRowAt: indexPath, point: .zero)
        }
    }
    
}


extension HomeViewControllerTests {
    func testTableViewCellConfiguration() {
        // Given
        let testTasks = [TaskModel(id: 1, todo: "Test", completed: false, userId: 1)]
        sut.showTasks(testTasks)
        
        // When
        let cell = sut.dataSource?.tableView(sut.tableView!, cellForRowAt: IndexPath(row: 0, section: 0)) as! TasksTBCell
        
        // Then
        XCTAssertEqual(cell.taskTitleLabel.text, "Test", "Cell should be configured with task title")
    }
}

