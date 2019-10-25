//
//  ViewController.swift
//  HolaTester
//
//  Created by Philip Shen on 10/23/19.
//  Copyright © 2019 Philip Shen. All rights reserved.
//

import UIKit
import HolaClient

class ViewController: UIViewController {
    
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet var retryButton: UIButton!
    @IBOutlet var stackView: UIStackView!
    
    lazy var requestService = HTTPRequestService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        attemptToConnect()
    }
    
    private func attemptToConnect() {
        loadingIndicator.startAnimating()
        retryButton.isHidden = true
        
        do {
            let host = try Hola.getURL()
            loadingIndicator.stopAnimating()
            requestService.host = host
            statusLabel.text = host
        }
        catch let error {
            loadingIndicator.stopAnimating()
            statusLabel.text = "Failed to get URL: \(error.localizedDescription)"
            retryButton.isHidden = false
        }
    }

    @IBAction func retryButtonPressed(_ sender: Any) {
        attemptToConnect()
    }
    
    @IBAction func sendDataUSARequestPressed(_ sender: Any) {
        let request = HTTPRequest(
            path: "/api/data?drilldowns=Nation&measures=Population",
            method: .get
        )
        
        requestService.execute(request) { data, error in
            if let data = data {
                print(String(data: data, encoding: .utf8)!)
            }
            
            if let error = error {
                print(error)
            }
        }
    }
}
