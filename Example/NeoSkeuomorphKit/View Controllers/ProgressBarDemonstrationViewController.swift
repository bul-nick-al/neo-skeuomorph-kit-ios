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

    private let background: CALayer = {
        let backgroud = CAGradientLayer()
        backgroud.colors = [
            UIColor(red: 241.0/255.0, green: 245.0/255.0, blue: 248.0/255.0, alpha: 1.0).cgColor,
            UIColor(red: 221.0/255.0, green: 231.0/255.0, blue: 243.0/255.0, alpha: 1.0).cgColor,
            UIColor(red: 229.0/255.0, green: 240.0/255.0, blue: 249.0/255.0, alpha: 1.0).cgColor
        ]
        return backgroud
    }()

    private let progressSlider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()

    private let changeButton: UIButton = {
        let button = UIButton()

        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Change", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.setTitleColor(.systemGray, for: .highlighted)

        return button
    }()

    @objc private func changeProgress(_ button: UIButton) {
        progressBar.setProgress(progressSlider.value, animated: true)
    }

    private let progressBar: ProgressBar = {
        let progressBar = ProgressBar()
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        return progressBar
    }()

    private func setLayout() {
        NSLayoutConstraint.activate([
            progressBar.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            progressBar.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            progressBar.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor)
        ])

        NSLayoutConstraint.activate([
            progressSlider.leadingAnchor.constraint(
                equalToSystemSpacingAfter: view.layoutMarginsGuide.leadingAnchor,
                multiplier: 1.0
            ),
            view.layoutMarginsGuide.bottomAnchor.constraint(
                equalToSystemSpacingBelow: progressSlider.bottomAnchor,
                multiplier: 1.0
            ),
            changeButton.leadingAnchor.constraint(
                equalToSystemSpacingAfter: progressSlider.trailingAnchor,
                multiplier: 1.0
            ),
            view.layoutMarginsGuide.trailingAnchor.constraint(
                equalToSystemSpacingAfter: changeButton.trailingAnchor,
                multiplier: 1.0
            ),
            progressSlider.centerYAnchor.constraint(equalTo: changeButton.centerYAnchor)
        ])
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.layer.addSublayer(background)
        view.addSubview(progressBar)
        view.addSubview(progressSlider)
        view.addSubview(changeButton)

        changeButton.addTarget(self, action: #selector(changeProgress(_:)), for: .touchUpInside)

        setLayout()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        background.frame = view.bounds
    }
}
