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
            (child as? ContainerView)?.elevation = sender.value
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
        view.addSubview(slider)
        NSLayoutConstraint.activate([
            slider.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            slider.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            slider.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor)
        ])

        let myCont = ContainerView(frame: CGRect(x: 80, y: 80, width: 150, height: 280))
        myCont.translatesAutoresizingMaskIntoConstraints = false

        let childView = UIView(frame: CGRect(x: 0, y: 0, width: 150, height: 280))
        childView.backgroundColor = UIColor(red: 227.0/255.0, green: 237.0/255.0, blue: 247.0/255.0, alpha: 1.0)
        childView.layer.cornerRadius = 40

        myCont.child = childView
        view.addSubview(myCont)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
