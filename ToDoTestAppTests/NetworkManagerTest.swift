//
//  NetworkManagerTest.swift
//  ToDoTestAppTests
//
//  Created by Muhammadjon Madaminov on 31/01/25.
//

import UIKit
@testable import ToDoTestApp
import XCTest



enum MockEndpoint: EndpointProtocol {
    
    case testURL, invalidURL
    
    var path: String {
        switch self {
        case .testURL:
            return "https://example.com"
        case .invalidURL:
            return ""
        }
    }
    
    var url: URL? {
        switch self {
        case .testURL:
            let components = URLComponents(string: path)
            return components?.url
        case .invalidURL:
            return nil
        }
    }
    
    
}


class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (URLResponse, Data?))?
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            XCTFail("Request handler not set.")
            return
        }
        
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            if let data = data {
                client?.urlProtocol(self, didLoad: data)
            }
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
    
    override func stopLoading() {}
}

class NetworkManagerTests: XCTestCase {
    var networkManager: NetworkManager!
    var mockSession: URLSession!
    
    struct MockModel: Codable, Equatable {
        let id: Int
        let name: String
    }
    
    struct InvalidMockModel: Codable, Equatable {
        let id: String
        let name: String
    }
    
    override func setUp() {
        super.setUp()
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        mockSession = URLSession(configuration: config)
        networkManager = NetworkManager(session: mockSession)
        MockURLProtocol.requestHandler = nil
    }
    
    override func tearDown() {
        networkManager = nil
        mockSession = nil
        super.tearDown()
    }
    
    // MARK: - Test Cases
    
    func testFetchData_Success() {
        //Given
        let expectation = self.expectation(description: "Success")
        let mockData = #"{"id": 1, "name": "Test"}"#.data(using: .utf8)!
        let endpoint = MockEndpoint.testURL
        
        //when
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, mockData)
        }
        
        //then
        networkManager.fetchData(for: endpoint, type: MockModel.self) { result in
            switch result {
            case .success(let model):
                XCTAssertEqual(model, MockModel(id: 1, name: "Test"))
            case .failure(let error):
                XCTFail("Unexpected error: \(error)")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testFetchData_InvalidURL() {
        let expectation = self.expectation(description: "Invalid URL")
        let endpoint = MockEndpoint.invalidURL
        
        networkManager.fetchData(for: endpoint, type: MockModel.self) { result in
            switch result {
            case .success:
                XCTFail("Expected failure, got success")
            case .failure(let error):
                XCTAssertEqual(error as? NetworkErrors, .invalidURL)
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testFetchData_ServerError() {
        let expectation = self.expectation(description: "Server Error")
        let endpoint = MockEndpoint.testURL
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 500, httpVersion: nil, headerFields: nil)!
            return (response, nil)
        }
        
        networkManager.fetchData(for: endpoint, type: MockModel.self) { result in
            switch result {
            case .success:
                XCTFail("Expected failure, got success")
            case .failure(let error):
                guard case .serverError(let code) = error as? NetworkErrors else {
                    XCTFail("Unexpected error: \(error)")
                    return
                }
                XCTAssertEqual(code, 500)
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testFetchData_InvalidData() {
        let expectation = self.expectation(description: "Invalid Data")
        let endpoint = MockEndpoint.testURL

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, Data())  // Ensure `nil` data is returned
        }

        networkManager.fetchData(for: endpoint, type: MockModel.self) { result in
            switch result {
            case .success:
                XCTFail("Expected failure, got success")
            case .failure(let error):
                XCTAssertTrue(error is NetworkErrors, "Expected a NetworkErrors type, but got \(error)")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }
    
    func testFetchData_DecodingError() {
        let expectation = self.expectation(description: "Decoding Error")
        let invalidData = #"{"invalid": "data"}"#.data(using: .utf8)!
        let endpoint = MockEndpoint.testURL
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, invalidData)
        }
        
        networkManager.fetchData(for: endpoint, type: MockModel.self) { result in
            switch result {
            case .success:
                XCTFail("Expected failure, got success")
            case .failure(let error):
                if case .decodingError = error as? NetworkErrors {
                    // Success
                } else {
                    XCTFail("Unexpected error: \(error)")
                }
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testFetchData_NetworkError() {
        let expectation = self.expectation(description: "Network Error")
        let endpoint = MockEndpoint.testURL
        
        MockURLProtocol.requestHandler = { request in
            throw NSError(domain: "Test", code: -1, userInfo: nil)
        }
        
        networkManager.fetchData(for: endpoint, type: MockModel.self) { result in
            switch result {
            case .success:
                XCTFail("Expected failure, got success")
            case .failure(let error):
                XCTAssertNotNil(error)
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testFetchData_InvalidResponse() {
        let expectation = self.expectation(description: "Invalid Response")
        let endpoint = MockEndpoint.testURL
        
        MockURLProtocol.requestHandler = { request in
            let response = URLResponse(url: request.url!, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
            return (response, nil)
        }
        
        networkManager.fetchData(for: endpoint, type: MockModel.self) { result in
            switch result {
            case .success:
                XCTFail("Expected failure, got success")
            case .failure(let error):
                XCTAssertEqual(error as? NetworkErrors, .invalidResponse)
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
    }
}
