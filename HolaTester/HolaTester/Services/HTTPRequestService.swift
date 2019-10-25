//
//  RequestService.swift
//  HolaTester
//
//  Created by Phil Shen on 10/25/19.
//  Copyright © 2019 Philip Shen. All rights reserved.
//

import Foundation
import os.log

class HTTPRequestService {
    
    typealias Handler = (Data?, Error?) -> Void
    
    let urlSession: URLSession
    var host: String? {
        didSet {
            os_log("Setting HTTPRequestService host to \"%@\"", host ?? "nil")
        }
    }
    var auth: String?
    
    init(urlSession: URLSession = .shared, host: String? = nil, auth: String? = nil) {
        self.urlSession = urlSession
        self.host = host
        self.auth = auth
    }
    
    @discardableResult
    func execute(_ request: HTTPRequest, completion: @escaping Handler) -> URLSessionDataTask? {
        guard let host = host else {
            completion(nil, HTTPRequestError.noURL)
            return nil
        }
        
        os_log("Sending request to %@: %@", type: .info, host, request.description)
      
        // Get the headers
        guard var urlRequest = request.urlRequest(host: host) else {
            fatalError("Unable to get URLRequest from HTTP request: \(request)")
        }
        
        var headers = ["Content-Type": "application/json"]
        if let auth = auth {
            headers["Authorization"] = auth
        }
        urlRequest.allHTTPHeaderFields = headers
        
        let dataTask = urlSession.dataTask(with: urlRequest) { data, response, error in
            // Check for HTTP response error
            if
                let response = response as? HTTPURLResponse,
                response.statusCode >= 400
            {
                let error = HTTPError(statusCode: response.statusCode)
                return completion(nil, error)
            }
            
            if let error = error {
                completion(data, error)
            } else {
                completion(data, nil)
            }
        }
        dataTask.resume()
        
        return dataTask
    }
    
}
