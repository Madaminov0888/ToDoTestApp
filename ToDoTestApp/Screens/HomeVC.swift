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
    let coreDataManager: CoreDataManageable
    
    var tableView: UITableView?
    var tasks: [TaskModel] = [] {
        didSet {
            updateData(taskModels: tasks)
        }
    }
    var filteredTasks: [TaskModel] = [] {
        didSet {
            updateData(taskModels: filteredTasks)
        }
    }
    
    var dataSource: UITableViewDiffableDataSource<Section, TaskModel>?
    
    
    init(networkManager: NetworkManagerProtocol = NetworkManager(), coreDataManager: CoreDataManageable = CoreDataManager(configuration: .production)) {
        self.networkManager = networkManager
        self.coreDataManager = coreDataManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        configureSearchBar()
        loadTasks()
        setToolbarItem()
    }
    
    
    func configure() {
        self.view.backgroundColor = .systemBackground
        self.title = "Задачи"
        self.tableView = createTableView()
        configureTableView()
        configureDataSource()
    }
    
    
    
    private func configureSearchBar() {
        let searchController = UISearchController()
        searchController.searchResultsUpdater = self
        searchController.searchBar.tintColor = .systemYellow
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Поиск"
        navigationItem.searchController = searchController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.isToolbarHidden = false
        self.navigationController?.toolbar.backgroundColor = .secondarySystemBackground
        self.navigationController?.toolbar.tintColor = .systemYellow
        
        let toolbarAppearance = UIToolbarAppearance()
        toolbarAppearance.configureWithOpaqueBackground()
        toolbarAppearance.backgroundColor = .secondarySystemBackground
        self.navigationController?.toolbar.standardAppearance = toolbarAppearance
        self.navigationController?.toolbar.scrollEdgeAppearance = toolbarAppearance
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
        let countLabel = UILabel()
        countLabel.text = "\(tasks.count) Задач"
        countLabel.textColor = .gray
        countLabel.font = UIFont.systemFont(ofSize: 16)
        let labelItem = UIBarButtonItem(customView: countLabel)
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let editButton = UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"), style: .plain, target: self, action: #selector(newTaskTapped))

        self.toolbarItems = [flexibleSpace, labelItem, flexibleSpace, editButton]
    }
    
    
    @objc func newTaskTapped() {
        let newVC = EditTaskVC()
        newVC.onSave = { [weak self] task in
            guard let self = self else { return }
            self.coreDataManager.saveTask(task)
            self.handleTaskUpdate(task: task)
        }
        self.navigationController?.pushViewController(newVC, animated: true)
    }
}




//MARK: Network functions
extension HomeVC {
    
    func loadTasks() {
        let savedTasks = coreDataManager.fetchTasks()
        if !savedTasks.isEmpty {
            tasks = savedTasks.sorted(by: { $0.createdAt ?? .now > $1.createdAt ?? .now })
        } else {
            fetchTasks()
        }
    }
    
    func fetchTasks() {
        networkManager.fetchData(for: .todos, type: TaskResponse.self) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let taskResponse):
                DispatchQueue.main.async {
                    let tasksToDisplay = self.setTaskDetails(taskResponse.todos)
                    self.tasks = tasksToDisplay.sorted(by: { $0.createdAt ?? .now > $1.createdAt ?? .now })
                    tasksToDisplay.forEach({ self.coreDataManager.saveTask($0) })
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
    
    
    func handleTaskUpdate(task: TaskModel) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
            updateData(taskModels: tasks)
        } else {
            tasks.insert(task, at: 0)
        }
    }
}





//MARK: TableView
extension HomeVC: UITableViewDelegate {
    
    func createTableView() -> UITableView {
        let tableView = UITableView(frame: view.bounds)
        tableView.delegate = self
        tableView.register(TasksTBCell.self, forCellReuseIdentifier: TasksTBCell.identifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        return tableView
    }
    
    func configureTableView() {
        guard let tableView else { return }
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        let task = tasks[indexPath.row]
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: {
            return self.createPreviewView(for: task) // Custom preview UI
        }) { _ in
            return self.createContextMenu(for: task, at: indexPath)
        }
    }
    
    private func createContextMenu(for task: TaskModel, at indexPath: IndexPath) -> UIMenu {
        let editAction = UIAction(title: "Редактировать", image: UIImage(systemName: "square.and.pencil")) { _ in
            let newVC = EditTaskVC(task: task)
            newVC.onSave = { [weak self] task in
                guard let self = self else { return }
                coreDataManager.updateTask(task)
                self.handleTaskUpdate(task: task)
            }
            self.navigationController?.pushViewController(newVC, animated: true)
        }
        
        let deleteAction = UIAction(title: "Удалить", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
            let id = self.tasks[indexPath.row].id
            self.tasks.removeAll(where: { $0.id == id })
            self.coreDataManager.deleteTask(task)
        }
        
        let shareAction = UIAction(title: "Поделиться", image: UIImage(systemName: "square.and.arrow.up")) { _ in
            print("Share")
        }
        
        return UIMenu(children: [editAction, shareAction, deleteAction])
    }
    
    // Handle Context Menu Display
    private func tableView(_ tableView: UITableView, willBeginContextMenuInteraction configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?) {
        applyBlurEffect()
    }
    
    // Remove Blur Effect when Menu Dismisses
    func tableView(_ tableView: UITableView, didEndContextMenuInteraction configuration: UIContextMenuConfiguration) {
        removeBlurEffect()
    }
    
    
    
    func configureDataSource() {
        guard let tableView else { return }
        dataSource = UITableViewDiffableDataSource(tableView: tableView, cellProvider: { tableView, indexPath, itemIdentifier in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: TasksTBCell.identifier, for: indexPath) as? TasksTBCell else {
                return UITableViewCell()
            }
            cell.configure(taskModel: itemIdentifier, coreDataManager: self.coreDataManager)
            cell.onTaskUpdate = { updatedTask in
                self.handleTaskUpdate(task: updatedTask)
            }
            return cell
        })
    }
    
    
    
    func updateData(taskModels: [TaskModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, TaskModel>()
        snapshot.appendSections([.main])
        snapshot.appendItems(taskModels)
        dataSource?.apply(snapshot, animatingDifferences: true)
        dataSource?.defaultRowAnimation = .fade
        setToolbarItem()
    }
    
    private func createPreviewView(for task: TaskModel) -> UIViewController {
        let previewVC = CSTBItemPreviewVC(for: task)
        previewVC.view.layoutIfNeeded() // Force layout calculation
        
        // Calculate required height
        let targetWidth = view.bounds.width - 40
        let calculatedSize = previewVC.view.systemLayoutSizeFitting(
            CGSize(width: targetWidth, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .defaultLow
        )
        
        previewVC.preferredContentSize = CGSize(
            width: targetWidth,
            height: calculatedSize.height
        )
        
        return previewVC
    }
}






//MARK: UISearchController
extension HomeVC: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text, !searchText.isEmpty else {
            updateData(taskModels: tasks)
            return
        }
        filteredTasks = tasks.filter({ $0.todo.lowercased().contains(searchText.lowercased()) })
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        updateData(taskModels: tasks)
    }
}




import SwiftUI
#Preview {
    SwiftUIPreview(vc: UINavigationController(rootViewController: HomeVC()))
        .ignoresSafeArea()
}
