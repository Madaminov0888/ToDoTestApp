//
//  HomeRouterProtocol.swift
//  ToDoTestApp
//
//  Created by Muhammadjon Madaminov on 30/01/25.
//

import UIKit


protocol HomeRouterProtocol: AnyObject {
    func navigateToEditTask(onSave: @escaping (_ task: TaskModel) -> Void)
    func navigateToEditTask(_ task: TaskModel, onSave: @escaping (_ task: TaskModel) -> Void)
}


class HomeRouter: HomeRouterProtocol {
    weak var viewController: UIViewController?
    
    static func createModule() -> UIViewController {
        let view = HomeViewController()
        let presenter = HomePresenter()
        let interactor = HomeInteractor()
        let router = HomeRouter()
        
        view.presenter = presenter
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        interactor.output = presenter
        router.viewController = view
        
        return view
    }
    
    
    func navigateToEditTask(onSave: @escaping (_ task: TaskModel) -> Void) {
        let newVC = EditTaskVC()
        newVC.onSave = onSave
        viewController?.navigationController?.pushViewController(newVC, animated: true)
    }
    
    func navigateToEditTask(_ task: TaskModel, onSave: @escaping (_ task: TaskModel) -> Void) {
        let newVC = EditTaskVC(task: task)
        newVC.onSave = onSave
        viewController?.navigationController?.pushViewController(newVC, animated: true)
    }
}
