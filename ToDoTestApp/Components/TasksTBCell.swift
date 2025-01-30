//
//  TasksTBCell.swift
//  ToDoTestApp
//
//  Created by Muhammadjon Madaminov on 28/01/25.
//

import UIKit

class TasksTBCell: UITableViewCell {
    
    static let identifier = "TaskTable"
    
    var coreDataManager: CoreDataManageable?
    var onTaskUpdate: ((TaskModel) -> Void)?
    
    var taskTitleLabel = CSTextLabel(fontSize: 26, textAlignment: .left)
    var taskBodyLabel = CSTextLabel(font: .preferredFont(forTextStyle: .title3), textAlignment: .left)
    var taskDateLabel = CSTextLabel(font: .preferredFont(forTextStyle: .body), textAlignment: .left)
    var toggleButton = CSToggleButton(frame: .zero)
    
    let padding: CGFloat = 10
    
    var task: TaskModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    func configure(taskModel: TaskModel, coreDataManager: CoreDataManageable) {
        self.task = taskModel
        self.coreDataManager = coreDataManager
        self.contentView.backgroundColor = .systemBackground
        configureToggleButton()
        configureTaskTitle()
        configureBody()
        configureDateLabel()
        updateTitleStyle()
    }
    
    private func configureToggleButton() {
        guard let task = self.task else { return }
        toggleButton.setState(isCompleted: task.completed)
        self.contentView.addSubview(toggleButton)
        
        toggleButton.onToggle = { [weak self] isOn in
            guard let self = self, var task = self.task else { return }
            
            task.completed = isOn
            self.coreDataManager?.updateTask(task)
            self.updateTitleStyle()
            self.onTaskUpdate?(task)
        }
        
        NSLayoutConstraint.activate([
            toggleButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            toggleButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            toggleButton.widthAnchor.constraint(equalToConstant: 30),
            toggleButton.heightAnchor.constraint(equalToConstant: 30),
        ])
    }
    
    private func configureTaskTitle() {
        guard let task = self.task else { return }
        taskTitleLabel.text = task.todo
        self.contentView.addSubview(taskTitleLabel)
        
        NSLayoutConstraint.activate([
            taskTitleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            taskTitleLabel.leadingAnchor.constraint(equalTo: toggleButton.trailingAnchor, constant: padding),
            taskTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            taskTitleLabel.centerYAnchor.constraint(equalTo: toggleButton.centerYAnchor)
        ])
    }
    
    
    private func configureBody() {
        guard let task = self.task else { return }
        taskBodyLabel.text = task.description
        contentView.addSubview(taskBodyLabel)
        
        NSLayoutConstraint.activate([
            taskBodyLabel.topAnchor.constraint(equalTo: taskTitleLabel.bottomAnchor, constant: padding),
            taskBodyLabel.leadingAnchor.constraint(equalTo: taskTitleLabel.leadingAnchor),
            taskBodyLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
        ])
    }
    
    
    private func configureDateLabel() {
        guard let task = self.task else { return }
        taskDateLabel.text = task.createdAt?.formattedDate()
        contentView.addSubview(taskDateLabel)
        
        NSLayoutConstraint.activate([
            taskDateLabel.topAnchor.constraint(equalTo: taskBodyLabel.bottomAnchor, constant: padding),
            taskDateLabel.leadingAnchor.constraint(equalTo: taskTitleLabel.leadingAnchor),
            taskDateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding),
            taskDateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
        ])
    }
    
    private func updateTitleStyle() {
        guard let task = task else { return }
        
        let attributes: [NSAttributedString.Key: Any] = [
            .strikethroughStyle: task.completed ? NSUnderlineStyle.single.rawValue : 0,
            .strikethroughColor: UIColor.label
        ]
        
        taskTitleLabel.attributedText = NSAttributedString(
            string: task.todo,
            attributes: attributes
        )
        taskTitleLabel.textColor = task.completed ? .secondaryLabel : .label
        taskBodyLabel.textColor = task.completed ? .secondaryLabel : .label
    }

}
