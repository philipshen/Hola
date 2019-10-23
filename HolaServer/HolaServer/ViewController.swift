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
    
    @IBOutlet var hostTextField: NSTextField!
    @IBOutlet var textView: NSTextView!
    
    lazy var logService = LogService(delegate: self)
    lazy var server = Server(logService: logService)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hostTextField.delegate = self
        textView.isEditable = false
        
        server.publish()
    }

}

// MARK: - NSTextFieldDelegate
extension ViewController: NSTextFieldDelegate {
    
    func controlTextDidChange(_ obj: Notification) {
        
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
