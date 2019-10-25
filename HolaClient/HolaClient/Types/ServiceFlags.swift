//
//  ServiceFlags.swift
//  HolaClient
//
//  Created by Phil Shen on 10/24/19.
//  Copyright © 2019 Philip Shen. All rights reserved.
//

import Foundation
import dnssd

struct ServiceFlags: OptionSet {
    
    let rawValue: DNSServiceFlags
    
    init(rawValue: DNSServiceFlags) {
        self.rawValue = rawValue
    }
    
    // Options
    public static let moreComing = ServiceFlags(rawValue: DNSServiceFlags(kDNSServiceFlagsMoreComing))
    
    public static let add = ServiceFlags(rawValue: DNSServiceFlags(kDNSServiceFlagsAdd))
    
    public static let browseDomains = ServiceFlags(rawValue: DNSServiceFlags(kDNSServiceFlagsBrowseDomains))
    
    public static let registrationDomains = ServiceFlags(rawValue: DNSServiceFlags(kDNSServiceFlagsRegistrationDomains))
    
}
