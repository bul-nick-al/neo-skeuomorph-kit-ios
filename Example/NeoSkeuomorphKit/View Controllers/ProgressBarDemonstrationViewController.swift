//
//  ProgressBarDemonstrationViewController.swift
//  NeoSkeuomorphKit_Example
//
//  Created by Николай Булдаков on 02/04/2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import NeoSkeuomorphKit

class ProgressBarDemonstrationViewController: UIViewController {

    let background: CALayer = {
        let backgroud = CAGradientLayer()
        backgroud.colors = [
            UIColor(red: 241.0/255.0, green: 245.0/255.0, blue: 248.0/255.0, alpha: 1.0).cgColor,
            UIColor(red: 221.0/255.0, green: 231.0/255.0, blue: 243.0/255.0, alpha: 1.0).cgColor,
            UIColor(red: 229.0/255.0, green: 240.0/255.0, blue: 249.0/255.0, alpha: 1.0).cgColor
        ]
        return backgroud
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.layer.addSublayer(background)

        let progressBar = ProgressBar()
        progressBar.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(progressBar)

        progressBar.progress = 0.03
        NSLayoutConstraint.activate([
            progressBar.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            progressBar.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            progressBar.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            progressBar.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor)
        ])
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        background.frame = view.bounds
    }
}
