//
//  CSTableItemPreview.swift
//  ToDoTestApp
//
//  Created by Muhammadjon Madaminov on 29/01/25.
//

import UIKit

class CSTBItemPreviewVC: UIViewController {
    
    private var titleLabel = CSTextLabel(fontSize: 26, textAlignment: .left)
    private var bodyLabel = CSTextLabel(font: .preferredFont(forTextStyle: .title3), textAlignment: .left)
    private var dateLabel = CSTextLabel(font: .preferredFont(forTextStyle: .body), textAlignment: .left)
    
    var task: TaskModel?
    let padding: CGFloat = 8
    
    
    
    init(for task: TaskModel) {
        self.task = task
        super.init(nibName: nil, bundle: nil)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private let containerView = UIView()
    
    func configure() {
        guard task != nil else { return }
        view.backgroundColor = .clear
        
        // Configure container view
        containerView.backgroundColor = .secondarySystemBackground
        containerView.layer.cornerRadius = 10
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        
        // Container constraints
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: view.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            containerView.widthAnchor.constraint(equalToConstant: view.bounds.width - 40)
        ])
        
        configureTitleLabel()
        configureBodyLabel()
        configureDateLabel()
    }
    
    private func configureTitleLabel() {
        guard let task else { return }
        titleLabel.text = task.todo
        containerView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: padding),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: padding),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -padding)
        ])
    }
    
    private func configureBodyLabel() {
        guard let task else { return }
        bodyLabel.text = task.description
        bodyLabel.numberOfLines = 2 // Limit body text to 2 lines
        containerView.addSubview(bodyLabel)
        
        NSLayoutConstraint.activate([
            bodyLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: padding),
            bodyLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: padding),
            bodyLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -padding)
        ])
    }
    
    private func configureDateLabel() {
        guard let task else { return }
        dateLabel.text = task.createdAt?.formattedDate()
        containerView.addSubview(dateLabel)
        
        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: bodyLabel.bottomAnchor, constant: padding),
            dateLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: padding),
            dateLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -padding),
            dateLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -padding)
        ])
    }
}



import SwiftUI
#Preview {
    SwiftUIPreview(vc: CSTBItemPreviewVC(for: TaskModel(id: 1, todo: "asfd", description: "sfsdfsgssf",completed: true, userId: 1)))
        .frame(width: 300, height: 300)
}
