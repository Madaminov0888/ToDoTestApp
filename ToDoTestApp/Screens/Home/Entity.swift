//
//  TaskModel.swift
//  ToDoTestApp
//
//  Created by Muhammadjon Madaminov on 28/01/25.
//

import Foundation

struct TaskResponse: Codable {
    let todos: [TaskModel]
    let total: Int
    let skip: Int
    let limit: Int
    
    init(todos: [TaskModel]) {
        self.todos = todos
        self.total = todos.count
        self.skip = 0
        self.limit = 0
    }
}

struct TaskModel: Identifiable, Hashable, Codable {
    let id: Int
    var todo: String
    var description: String?
    var createdAt: Date?
    var completed: Bool
    let userId: Int
}



extension TaskModel {
    var shareText: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy HH:mm" // Example: Jan 30, 2025 14:45
        let createdAtString = createdAt.map { dateFormatter.string(from: $0) } ?? "Unknown Date"
        
        let completionStatus = completed ? "✅ Completed" : "❌ Not Completed"
        
        return """
        📝 Task: \(todo)
        📄 Description: \(description ?? "No description")
        📅 Created At: \(createdAtString)
        ✅ Status: \(completionStatus)
        """
    }
}
