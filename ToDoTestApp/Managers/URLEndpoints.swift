//
//  URLEndpoints.swift
//  ToDoTestApp
//
//  Created by Muhammadjon Madaminov on 28/01/25.
//

import Foundation



protocol EndpointProtocol {    
    var path: String { get }
    var url: URL? { get }
}



enum Endpoint: EndpointProtocol {
    case todos
    
    static let baseURL = "https://dummyjson.com"

    var path: String {
        switch self {
        case .todos:
            return "/todos"
        }
    }

    
    var url: URL? {
        let components = URLComponents(string: Endpoint.baseURL + path)
        return components?.url
    }
}
