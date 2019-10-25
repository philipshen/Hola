//
//  Dict+NetServiceError.swift
//  HolaClient
//
//  Created by Philip Shen on 10/24/19.
//  Copyright © 2019 Philip Shen. All rights reserved.
//

import Foundation

extension Dictionary where Key == String, Value == NSNumber {
    
    var netServiceErrorInfo: (domain: NSNumber, code: NSNumber)? {
        guard
            let domain = self[NetService.errorDomain],
            let code = self[NetService.errorCode]
        else {
            return nil
        }
        
        return (domain, code)
    }
    
}
