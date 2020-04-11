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

    @objc func detectSwitchToggle(_ sender: Switch) {
        label.text = sender.isOn ? "On" : "Off"
    }

    let background: CALayer = {
        let backgroud = CAGradientLayer()
        backgroud.colors = [
            UIColor(red: 241.0/255.0, green: 245.0/255.0, blue: 248.0/255.0, alpha: 1.0).cgColor,
            UIColor(red: 235.0/255.0, green: 243.0/255.0, blue: 250.0/255.0, alpha: 1.0).cgColor,
            UIColor(red: 229.0/255.0, green: 240.0/255.0, blue: 249.0/255.0, alpha: 1.0).cgColor
        ]
        return backgroud
    }()

    lazy var label: UILabel = {
        let label = UILabel()
        label.text = mySwitch.isOn ? "On" : "Off"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let mySwitch: Switch = {
        let mySwitch = Switch()
        mySwitch.translatesAutoresizingMaskIntoConstraints = false
        mySwitch.addTarget(self, action: #selector(detectSwitchToggle(_:)), for: .valueChanged)
        return mySwitch
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.addSublayer(background)
        view.addSubview(mySwitch)
        view.addSubview(label)
        background.frame = view.bounds

        NSLayoutConstraint.activate([
            mySwitch.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            mySwitch.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: mySwitch.trailingAnchor, constant: 40),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        view.layer.sublayers?[0].frame = view.bounds
    }
}
