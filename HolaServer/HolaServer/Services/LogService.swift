//
//  LogService.swift
//  BonjourPlayground
//
//  Created by Philip Shen on 10/21/19.
//  Copyright © 2019 Philip Shen. All rights reserved.
//

import Foundation

/**
 Log strings with a classification and informs its delegate of the (formatted) log
 */
class LogService {
    
    weak var delegate: LogServiceDelegate?
    
    init(delegate: LogServiceDelegate? = nil) {
        self.delegate = delegate
    }
    
    func log(_ log: Log) {
        delegate?.logService(self, didReceiveLog: log)
    }
    
}
