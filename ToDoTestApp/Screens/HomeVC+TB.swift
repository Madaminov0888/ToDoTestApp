//
//  HomeVC+TB.swift
//  ToDoTestApp
//
//  Created by Muhammadjon Madaminov on 29/01/25.
//

import UIKit



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
            print("completed")
        }
        
        let deleteAction = UIAction(title: "Удалить", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
            print("deleted")
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
            cell.configure(taskModel: itemIdentifier)
            return cell
        })
    }
    
    
    
    func updateData() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, TaskModel>()
        snapshot.appendSections([.main])
        snapshot.appendItems(tasks)
        dataSource?.apply(snapshot, animatingDifferences: true)
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
