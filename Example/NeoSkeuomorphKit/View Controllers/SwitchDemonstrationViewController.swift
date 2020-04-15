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

    let mySwitch: Switch = {
        let mySwitch = Switch()
        mySwitch.translatesAutoresizingMaskIntoConstraints = false
        return mySwitch
    }()

    let mySwitch3: Switch3 = {
        let mySwitch = Switch3()
        mySwitch.translatesAutoresizingMaskIntoConstraints = false
        return mySwitch
    }()

    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 15
        return stackView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.addSublayer(background)
        view.addSubview(stackView)

        stackView.addArrangedSubview(mySwitch)
        stackView.addArrangedSubview(mySwitch3)

        background.frame = view.bounds

        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        view.layer.sublayers?[0].frame = view.bounds
    }
}
