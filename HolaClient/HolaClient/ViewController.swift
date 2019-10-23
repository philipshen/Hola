//
//  ViewController.swift
//  HolaClient
//
//  Created by Phil Shen on 10/22/19.
//  Copyright © 2019 Philip Shen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let client: BonjourClient = .shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func testSendButtonPressed(_ sender: Any) {
        client.send(message: "What's up?")
    }
    
}
