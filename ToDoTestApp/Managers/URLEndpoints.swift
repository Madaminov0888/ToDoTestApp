//
//  URLEndpoints.swift
//  ToDoTestApp
//
//  Created by Muhammadjon Madaminov on 28/01/25.
//

import Foundation


enum Endpoint {
    case todos

    var path: String {
        switch self {
        case .todos:
            return "/todos"
        }
    }

    var url: URL? {
        let baseURL = "https://dummyjson.com"
        var components = URLComponents(string: baseURL + path)
        return components?.url
    }
}
