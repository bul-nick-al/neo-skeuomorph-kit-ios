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
        let myCont = ContainerView()
        myCont.cornerRadius = 40
        myCont.translatesAutoresizingMaskIntoConstraints = false
        let childView = UIView(frame: CGRect(x: 40, y: 40, width: 150, height: 280))
        childView.backgroundColor = .green
        myCont.child = childView
        view.addSubview(myCont)
//        NSLayoutConstraint.activate([
//            myCont.widthAnchor.constraint(equalToConstant: 200),
//            myCont.heightAnchor.constraint(equalToConstant: 200),
//            myCont.centerYAnchor.constraint(equalTo: view.centerYAnchor),
//            myCont.centerXAnchor.constraint(equalTo: view.centerXAnchor)
//        ])
        // Do any additional setup after loading the view, typically from a nib.
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
