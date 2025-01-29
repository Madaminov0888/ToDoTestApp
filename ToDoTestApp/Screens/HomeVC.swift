//
//  HomeVC.swift
//  ToDoTestApp
//
//  Created by Muhammadjon Madaminov on 28/01/25.
//

import UIKit

class HomeVC: UIViewController {
    
    enum Section {
        case main
    }
    
    let networkManager: NetworkManagerProtocol
    
    var tableView: UITableView?
    var tasks: [TaskModel] = [] {
        didSet {
            updateData()
        }
    }
    var dataSource: UITableViewDiffableDataSource<Section, TaskModel>?
    
    
    init(networkManager: NetworkManagerProtocol = NetworkManager()) {
        self.networkManager = networkManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        getTasks()
        setToolbarItem()
    }
    
    
    func configure() {
        self.view.backgroundColor = .systemBackground
        self.title = "Задачи"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.isToolbarHidden = false
        self.navigationController?.toolbar.backgroundColor = .secondarySystemBackground
        self.navigationController?.toolbar.tintColor = .systemYellow
        self.tableView = createTableView()
        configureTableView()
        configureDataSource()
    }
    
    func applyBlurEffect() {
        let blurEffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = view.bounds
        blurView.tag = 999  // Identifier for removal
        view.addSubview(blurView)
    }

    func removeBlurEffect() {
        view.subviews.first { $0.tag == 999 }?.removeFromSuperview()
    }
    
    func setToolbarItem() {
        // Label displaying the number of tasks
        let countLabel = UILabel()
        countLabel.text = "\(tasks.count) Задач"
        countLabel.textColor = .gray
        countLabel.font = UIFont.systemFont(ofSize: 16)
        let labelItem = UIBarButtonItem(customView: countLabel)
        
        // Flexible space to push "Edit" to the right
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        // Edit button
        let editButton = UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"), style: .plain, target: self, action: nil)

        // Set toolbar items
        self.toolbarItems = [flexibleSpace, labelItem, flexibleSpace, editButton]
    }
}




//MARK: Network functions
extension HomeVC {
    func getTasks() {
        networkManager.fetchData(for: .todos, type: TaskResponse.self) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let taskResponse):
                DispatchQueue.main.async {
                    let tasksToDisplay = self.setTaskDetails(taskResponse.todos)
                    self.tasks = tasksToDisplay
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func setTaskDetails(_ tasks: [TaskModel]) -> [TaskModel] {
        var updatedTasks = tasks
        for i in 0..<updatedTasks.count {
            updatedTasks[i].createdAt = Date()
            updatedTasks[i].description = updatedTasks[i].todo
        }
        return updatedTasks
    }
}




import SwiftUI
#Preview {
    SwiftUIPreview(vc: UINavigationController(rootViewController: HomeVC()))
        .ignoresSafeArea()
}
