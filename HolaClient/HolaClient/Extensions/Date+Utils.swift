//
//  Date+Utils.swift
//  HolaClient
//
//  Created by Phil Shen on 10/25/19.
//  Copyright © 2019 Philip Shen. All rights reserved.
//

import Foundation

extension Date {
    
    func adding(seconds: Int) -> Date {
        return Calendar.current.date(byAdding: .second, value: seconds, to: Date())!
    }
    
}
