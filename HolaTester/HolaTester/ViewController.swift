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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        Hola.getURLAsync { url, error in
            print(url)
            print(error)
        }
//        DispatchQueue.global(qos: .background).async {
//            let url = Hola.getURL()
//            print(url)
//        }
    }

}

