//
//  ViewController.swift
//  BonjourPlayground
//
//  Created by Philip Shen on 10/21/19.
//  Copyright © 2019 Philip Shen. All rights reserved.
//

import Cocoa
import os.log

class ViewController: NSViewController {
    
    @IBOutlet var textView: NSTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.isEditable = false
        
        let logService = LogService(delegate: self)
        let service = BonjourServer(logService: logService)
        service.publish()
    }

}

// MARK: - LogServiceDelegate
extension ViewController: LogServiceDelegate {
    
    func logService(_ logService: LogService, didReceiveLog log: Log) {
        DispatchQueue.main.async {
            let attrString = NSAttributedString(string: log.formatted() + "\n", attributes: [
                .foregroundColor: self.getColor(log: log)
            ])
            os_log("%@", attrString.string)
            self.textView.textStorage?.append(attrString)
        }
    }
    
}

// MARK: - Private utility methods
private extension ViewController {
    
    func getColor(log: Log) -> NSColor {
        switch log.category {
        case .success:
            return .green
        case .error:
            return .red
        case .default:
            return UserDefaults.standard.string(forKey: "AppleInterfaceStyle") == "Dark"
                ? .white
                : .black
        }
    }
    
}
