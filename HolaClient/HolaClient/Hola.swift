//
//  Hola.swift
//  HolaClient
//
//  Created by Phil Shen on 10/23/19.
//  Copyright © 2019 Philip Shen. All rights reserved.
//

import Foundation

public class Hola {
    
    /**
     Gets the url string, synchronously synchronously
     */
    public static func getURL() throws -> String {
        let group = DispatchGroup()
        
        var url: String?
        var error: Error?
        
        group.enter()
        Hola.getURLAsync { fetchedUrl, fetchedError in
            url = fetchedUrl
            error = fetchedError
            group.leave()
        }
        group.wait()
        
        if let url = url {
            return url
        } else if let error = error {
            throw error
        } else {
            throw UnknownError("No url returned")
        }
    }
    
    public static func getURLAsync(completion: @escaping (String?, Error?) -> Void) {
        Client.shared.getURL(completion: completion)
    }
    
}
