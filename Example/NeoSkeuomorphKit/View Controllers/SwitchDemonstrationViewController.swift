//
//  SwitchDemonstrationViewController.swift
//  NeoSkeuomorphKit_Example
//
//  Created by Николай Булдаков on 22/03/2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import NeoSkeuomorphKit

class SwitchDemonstrationViewController: UIViewController {

    let background: CALayer = {
        let backgroud = CAGradientLayer()
        backgroud.colors = [
            UIColor(red: 241.0/255.0, green: 245.0/255.0, blue: 248.0/255.0, alpha: 1.0).cgColor,
            UIColor(red: 235.0/255.0, green: 243.0/255.0, blue: 250.0/255.0, alpha: 1.0).cgColor,
            UIColor(red: 229.0/255.0, green: 240.0/255.0, blue: 249.0/255.0, alpha: 1.0).cgColor
        ]
        return backgroud
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.addSublayer(background)
        let mySwitch = Switch()
        view.addSubview(mySwitch)
        background.frame = view.bounds
        mySwitch.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mySwitch.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            mySwitch.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        view.layer.sublayers?[0].frame = view.bounds
    }
}
