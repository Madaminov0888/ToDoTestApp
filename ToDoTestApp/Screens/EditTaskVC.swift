//
//  EditTaskVC.swift
//  ToDoTestApp
//
//  Created by Muhammadjon Madaminov on 29/01/25.
//

import UIKit

//MARK: EditTaskVC
/// It is better solution not to use VIPER on small ViewControllers

class EditTaskVC: UIViewController {
    
    var task: TaskModel
    var coreDataManager: CoreDataManager?
    var onSave: ((TaskModel) -> Void)?
    
    var dateLabel = CSTextLabel(font: .preferredFont(forTextStyle: .body), textAlignment: .left)
    var titleTextField = CSTextField()
    var bodyTextView = CSTextView(frame: .zero)
    
    init(task: TaskModel) {
        self.task = task
        super.init(nibName: nil, bundle: nil)
    }
    
    init() {
        let uniqueInt = Int(Date().timeIntervalSince1970 * 1000)
        self.task = TaskModel(id: uniqueInt, todo: "", createdAt: Date(), completed: false, userId: uniqueInt)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let text = titleTextField.text { task.todo = text }
        if let desc = bodyTextView.text { task.description = desc }
        if task.todo.isEmpty && (task.description == nil || task.description?.isEmpty == true) { return }
        onSave?(task)
    }
    
    private func configure() {
        view.backgroundColor = .systemBackground
        configureTitleField()
        configureDateLabel()
        configureBodyTextView()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.tintColor = .systemYellow
        navigationController?.setToolbarHidden(true, animated: true)
    }
    
    
    private func configureTitleField() {
        let padding: CGFloat = 20
    
        titleTextField.text = task.todo
        view.addSubview(titleTextField)
        
        NSLayoutConstraint.activate([
            titleTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: padding),
            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
        ])
    }
    
    private func configureDateLabel() {
        let padding: CGFloat = 20
        dateLabel.text = task.createdAt?.formattedDate()
        view.addSubview(dateLabel)
        
        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: padding),
            dateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            dateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
        ])
    }
    
    private func configureBodyTextView() {
        let padding: CGFloat = 20
        if (task.description?.isEmpty == false) { bodyTextView.text = task.description }
        view.addSubview(bodyTextView)
        
        NSLayoutConstraint.activate([
            bodyTextView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: padding),
            bodyTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            bodyTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            bodyTextView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -padding),
        ])
    }
    
}
