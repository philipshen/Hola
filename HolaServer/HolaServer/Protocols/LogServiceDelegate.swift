//
//  LogServiceDelegate.swift
//  BonjourPlayground
//
//  Created by Philip Shen on 10/21/19.
//  Copyright © 2019 Philip Shen. All rights reserved.
//

import Foundation

protocol LogServiceDelegate: class {
    func logService(_ logService: LogService, didReceiveLog log: Log)
}
