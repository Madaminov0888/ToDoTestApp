//
//  NetworkManager.swift
//  ToDoTestApp
//
//  Created by Muhammadjon Madaminov on 28/01/25.
//

import Foundation


protocol NetworkManagerProtocol {
    func fetchData<T:Codable>(for endpoint: Endpoint, type: T.Type, completion: @escaping (Result<T, Error>) -> Void)
}



class NetworkManager: NetworkManagerProtocol {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func fetchData<T: Codable>(for endpoint: Endpoint, type: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        guard let url = endpoint.url else {
            completion(.failure(NetworkErrors.invalidURL))
            return
        }

        let request = URLRequest(url: url)
        session.dataTask(with: request) { [weak self] data, response, error in
            guard let self else { return }
            self.handleResponse(data: data, response: response, error: error, completion: completion)
        }.resume()
    }
    
    
    private func handleResponse<T: Codable>(
        data: Data?,
        response: URLResponse?,
        error: Error?,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        if let error = error {
            completion(.failure(error))
            return
        }

        guard let data = data else {
            completion(.failure(NetworkErrors.invalidData))
            return
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            completion(.failure(NetworkErrors.invalidResponse))
            return
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            completion(.failure(NetworkErrors.serverError(statusCode: httpResponse.statusCode)))
            return
        }

        do {
            let decodedData = try JSONDecoder().decode(T.self, from: data)
            completion(.success(decodedData))
        } catch {
            completion(.failure(NetworkErrors.decodingError(error)))
        }
    }
    
}




enum NetworkErrors: Error {
    case invalidURL
    case invalidResponse
    case invalidData
    case decodingError(Error)
    case serverError(statusCode: Int)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return NSLocalizedString("The provided url is invalid. Please check the url", comment: "Message for invalid URL error")
        case .invalidResponse:
            return NSLocalizedString("The server response is invalid. Please try again later.", comment: "Message for invalid response error")
        case .invalidData:
            return NSLocalizedString("The received data is invalid or corrupted", comment: "Message for invalid data error")
        case .decodingError(let error):
            return NSLocalizedString("Failed to decode the data: \(error.localizedDescription)", comment: "Message for decoding error")
        case .serverError(let statusCode):
            return NSLocalizedString("The server returned an error with status code: \(statusCode)", comment: "Message for server error")
        }
    }
}
