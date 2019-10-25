//
//  HTTPRequest.swift
//  HolaTester
//
//  Created by Phil Shen on 10/25/19.
//  Copyright © 2019 Philip Shen. All rights reserved.
//

import Foundation

struct HTTPRequest {
    
    var path: String
    var method: HTTPMethod
    var body: [String:Any]?
    
    var description: String {
        "\(method.rawValue) \(path)"
    }
    
    init(path: String, method: HTTPMethod, body: [String:Any]? = nil) {
        self.path = path
        self.method = method
        self.body = body
    }
    
    func urlRequest(host: String) -> URLRequest? {
        let urlString = host + path
        
        guard let encodedURLString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            assertionFailure()
            return nil
        }
        
        guard let url = URL(string: encodedURLString) else {
            assertionFailure()
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        if let body = body {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
            }
            catch let error {
                assertionFailure(error.localizedDescription)
            }
        }
        
        return request
    }
    
}
