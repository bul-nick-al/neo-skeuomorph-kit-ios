//
//  ViewController.swift
//  NeoSkeuomorphKit
//
//  Created by Nikolay on 12/14/2019.
//  Copyright (c) 2019 Nikolay. All rights reserved.
//

import UIKit
import NeoSkeuomorphKit
class ViewController: UIViewController {
   @objc func changeShadow(_ sender: UISlider) {
        for child in view.subviews {
            (child as? ContainerView)?.layer.cornerRadius = CGFloat(Float(sender.value))
        }
    }

    @objc func changeShadowFromSegment(_ sender: UISegmentedControl) {
        func getEl(index: Int) -> ContainerView.Elevation {
            switch index {
            case 0:
                return .concaveHigh
            case 1:
                return .concaveMedium
            case 2:
                return .concaveLow
            case 3:
                return .concaveSlightly
            case 4:
                return .flat
            case 5:
                return .convexSlightly
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
        for child in view.subviews {
            (child as? ContainerView)?.elevation = getEl(index: sender.selectedSegmentIndex)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let backgroud = CAGradientLayer()
        backgroud.colors = [
            UIColor(red: 241.0/255.0, green: 245.0/255.0, blue: 248.0/255.0, alpha: 1.0).cgColor,
            UIColor(red: 221.0/255.0, green: 231.0/255.0, blue: 243.0/255.0, alpha: 1.0).cgColor,
            UIColor(red: 229.0/255.0, green: 240.0/255.0, blue: 249.0/255.0, alpha: 1.0).cgColor
        ]
        backgroud.frame = view.bounds
        view.layer.insertSublayer(backgroud, at: 0)
        let slider = UISlider()
        slider.maximumValue = 50
        slider.minimumValue = -50
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.addTarget(self, action: #selector(self.changeShadow(_:)), for: .valueChanged)
        let segments = UISegmentedControl(items: ["-4", "-3", "-2", "-1", "0", "1", "2", "3", "4"])
        segments.translatesAutoresizingMaskIntoConstraints = false
        segments.selectedSegmentIndex = 4
        segments.addTarget(self, action: #selector(self.changeShadowFromSegment(_:)), for: .valueChanged)
        view.addSubview(segments)
        view.addSubview(slider)
        NSLayoutConstraint.activate([
            segments.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            segments.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            segments.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor)
        ])
        NSLayoutConstraint.activate([
            slider.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            slider.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            slider.bottomAnchor.constraint(equalTo: segments.topAnchor)
        ])

        let myCont = ContainerView(frame: CGRect(x: 80, y: 80, width: 150, height: 280))
        myCont.translatesAutoresizingMaskIntoConstraints = false

        let childView = UIView(frame: CGRect(x: 0, y: 0, width: 150, height: 280))
        childView.backgroundColor = UIColor(red: 227.0/255.0, green: 237.0/255.0, blue: 247.0/255.0, alpha: 1.0)
        childView.layer.cornerRadius = 40
        view.addSubview(myCont)
        NSLayoutConstraint.activate([
            myCont.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            myCont.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            myCont.heightAnchor.constraint(equalToConstant: 250),
            myCont.widthAnchor.constraint(equalToConstant: 250)
        ])

        myCont.child = childView

//        NSLayoutConstraint.activate([
//            childView.trailingAnchor.constraint(equalTo: myCont.trailingAnchor),
//            childView.leadingAnchor.constraint(equalTo: myCont.leadingAnchor),
//            childView.topAnchor.constraint(equalTo: myCont.topAnchor),
//            childView.bottomAnchor.constraint(equalTo: myCont.bottomAnchor),
//            childView.widthAnchor.constraint(equalTo: myCont.widthAnchor)
//        ])

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
