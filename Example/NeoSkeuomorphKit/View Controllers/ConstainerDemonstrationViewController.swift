//
//  ViewController.swift
//  NeoSkeuomorphKit
//
//  Created by Nikolay on 12/14/2019.
//  Copyright (c) 2019 Nikolay. All rights reserved.
//

import UIKit
import NeoSkeuomorphKit

class ContainerDemonstrationViewController: UIViewController {
    @objc func changeShadow(_ sender: UISlider) {
        container.layer.cornerRadius = CGFloat(Float(sender.value))
    }

    @objc func changeShadowFromSegment(_ sender: UISegmentedControl) {
        func getElevation(index: Int) -> ContainerView<UIView>.Elevation {
            switch index {
            case 0:
                return .concaveHigh
            case 1:
                return .concaveMedium
            case 2:
                return .concaveLow
            case 3:
                return .concaveSlight
            case 4:
                return .flat
            case 5:
                return .convexSlight
            case 6:
                return .convexLow
            case 7:
                return .convexMedium
            case 8:
                return .convexHigh
            default:
                return .flat
            }
        }
        container.elevation = getElevation(index: sender.selectedSegmentIndex)
    }

    let background: CALayer = {
        let backgroud = CAGradientLayer()
        backgroud.colors = [
            UIColor(red: 241.0/255.0, green: 245.0/255.0, blue: 248.0/255.0, alpha: 1.0).cgColor,
            UIColor(red: 221.0/255.0, green: 231.0/255.0, blue: 243.0/255.0, alpha: 1.0).cgColor,
            UIColor(red: 229.0/255.0, green: 240.0/255.0, blue: 249.0/255.0, alpha: 1.0).cgColor
        ]
        return backgroud
    }()

    let cornerRadiusSlider: UISlider = {
        let slider = UISlider()
        slider.maximumValue = 175
        slider.minimumValue = 0
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()

    let elevationSegments: UISegmentedControl = {
        let segments = UISegmentedControl(items: ["-4", "-3", "-2", "-1", "0", "1", "2", "3", "4"])
        segments.translatesAutoresizingMaskIntoConstraints = false
        segments.selectedSegmentIndex = 4
        return segments
    }()

    var container: ContainerView<UIView>!

    let childView: UIView = {
        let childView = UIView(frame: CGRect(x: 0, y: 0, width: 150, height: 280))
        childView.backgroundColor = UIColor(red: 227.0/255.0, green: 237.0/255.0, blue: 247.0/255.0, alpha: 1.0)
        return childView
    }()

    func setLayoutConstraints() {
        NSLayoutConstraint.activate([
            elevationSegments.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            elevationSegments.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            elevationSegments.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
            elevationSegments.topAnchor.constraint(
                equalToSystemSpacingBelow: cornerRadiusSlider.bottomAnchor,
                multiplier: 1
            )
        ])
        NSLayoutConstraint.activate([
            cornerRadiusSlider.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            cornerRadiusSlider.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
        ])
        NSLayoutConstraint.activate([
            container.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            container.heightAnchor.constraint(equalToConstant: 250),
            container.widthAnchor.constraint(equalToConstant: 250)
        ])

        let topLayoutGuideline = UILayoutGuide()
        let bottomLayoutGuideline = UILayoutGuide()
        view.addLayoutGuide(topLayoutGuideline)
        view.addLayoutGuide(bottomLayoutGuideline)
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: topLayoutGuideline.bottomAnchor),
            container.bottomAnchor.constraint(equalTo: bottomLayoutGuideline.topAnchor),
            topLayoutGuideline.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            bottomLayoutGuideline.bottomAnchor.constraint(equalTo: cornerRadiusSlider.topAnchor),
            topLayoutGuideline.heightAnchor.constraint(equalTo: bottomLayoutGuideline.heightAnchor)
        ])
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        container = ContainerView(child: childView)
        container.strokeWidth = 1
        container.translatesAutoresizingMaskIntoConstraints = false

        background.frame = view.bounds
        view.layer.insertSublayer(background, at: 0)
        view.addSubview(elevationSegments)
        view.addSubview(cornerRadiusSlider)
        view.addSubview(container)
        elevationSegments.addTarget(self, action: #selector(changeShadowFromSegment(_:)), for: .valueChanged)
        cornerRadiusSlider.addTarget(self, action: #selector(changeShadow(_:)), for: .valueChanged)
        setLayoutConstraints()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        view.layer.sublayers?[0].frame = view.bounds
    }
}
