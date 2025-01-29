//
//  Date+.swift
//  ToDoTestApp
//
//  Created by Muhammadjon Madaminov on 29/01/25.
//

import Foundation


extension Date {
    func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        return formatter.string(from: self)
    }
}
