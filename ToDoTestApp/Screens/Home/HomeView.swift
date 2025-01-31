//
//  HomeViewController.swift
//  ToDoTestApp
//
//  Created by Muhammadjon Madaminov on 30/01/25.
//

import UIKit


protocol HomeViewProtocol: AnyObject {
    func showTasks(_ tasks: [TaskModel])
    func updateTaskCount(_ count: Int)
}



class HomeViewController: UIViewController, HomeViewProtocol {
    enum Section {
        case main
    }
    

    var userDefaults: UserDefaults = UserDefaults()
    var presenter: HomePresenterProtocol!
    
    var tableView: UITableView?
    var dataSource: UITableViewDiffableDataSource<Section, TaskModel>?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        configureSearchBar()
        presenter.viewDidLoad()
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
        blurView.tag = 999   //MARK: Removal identifier for blur
        view.addSubview(blurView)
    }

    func removeBlurEffect() {
        view.subviews.first { $0.tag == 999 }?.removeFromSuperview()
    }
    
    
    
    @objc func newTaskTapped() {
        presenter.didSelectAddTask()
    }
    
    func showTasks(_ tasks: [TaskModel]) {
        updateData(taskModels: tasks)
        updateTaskCount(tasks.count)
    }
    

    func updateTaskCount(_ count: Int) {
        let countLabel = UILabel()
        countLabel.text = "\(count) Задач"
        countLabel.textColor = .gray
        countLabel.font = UIFont.systemFont(ofSize: 16)
        let labelItem = UIBarButtonItem(customView: countLabel)
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let editButton = UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"), style: .plain, target: self, action: #selector(newTaskTapped))

        self.toolbarItems = [flexibleSpace, labelItem, flexibleSpace, editButton]
    }
}




//MARK: TableView
extension HomeViewController: UITableViewDelegate {
    
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
        
        let task = presenter.didGetItemFromIndexPath(indexPath)
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: {
            return self.createPreviewView(for: task)
        }) { _ in
            return self.createContextMenu(for: task)
        }
    }
    
    private func createContextMenu(for task: TaskModel) -> UIMenu {
        let editAction = UIAction(title: "Редактировать", image: UIImage(systemName: "square.and.pencil")) { _ in
            self.presenter.didSelectEditTask(task)
        }
        
        let deleteAction = UIAction(title: "Удалить", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
            self.presenter.didDeleteTask(task)
        }
        
        let shareAction = UIAction(title: "Поделиться", image: UIImage(systemName: "square.and.arrow.up")) { _ in
            print("Share")
        }
        
        return UIMenu(children: [editAction, shareAction, deleteAction])
    }
    
    
    private func tableView(_ tableView: UITableView, willBeginContextMenuInteraction configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?) {
        applyBlurEffect()
    }
    
    
    func tableView(_ tableView: UITableView, didEndContextMenuInteraction configuration: UIContextMenuConfiguration) {
        removeBlurEffect()
    }
    
    
    
    func configureDataSource() {
        guard let tableView else { return }
        dataSource = UITableViewDiffableDataSource(tableView: tableView, cellProvider: { tableView, indexPath, itemIdentifier in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: TasksTBCell.identifier, for: indexPath) as? TasksTBCell else {
                return UITableViewCell()
            }
            cell.configure(taskModel: itemIdentifier)
            cell.onTaskUpdate = { [weak self] updatedTask in
                guard let self else { return }
                self.presenter.didUpdateTask(updatedTask)
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
    }
    
    
    private func createPreviewView(for task: TaskModel) -> UIViewController {
        let previewVC = ItemPreviewVC(for: task)
        previewVC.view.layoutIfNeeded()
        
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
extension HomeViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        presenter.didUpdateSearchQuery(searchController.searchBar.text ?? "")
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        presenter.didGetTasks()
    }
}
