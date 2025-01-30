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
}

struct TaskModel: Identifiable, Hashable, Codable {
    let id: Int
    var todo: String
    var description: String?
    var createdAt: Date?
    var completed: Bool
    let userId: Int
}
