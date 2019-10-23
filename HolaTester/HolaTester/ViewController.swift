//
//  ViewController.swift
//  HolaTester
//
//  Created by Phil Shen on 10/23/19.
//  Copyright © 2019 Philip Shen. All rights reserved.
//

import UIKit
import HolaClient

class ViewController: UIViewController {
    
    @IBOutlet var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        do {
            loadingIndicator.startAnimating()
            let url = try Hola.getURL()
            loadingIndicator.stopAnimating()
            titleLabel.text = "Server found: \(url)"
        } catch let error {
            print(error)
        }
    }


}

