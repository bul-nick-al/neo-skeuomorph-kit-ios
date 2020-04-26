//
//  UIViewController+SizeChange.swift
//  NeoSkeuomorphKit_Example
//
//  Created by Николай Булдаков on 23.02.2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

extension UIViewController {
    func popDueToSizeChange() {
        /*This view controller was pushed in a table view while in the split view controller's
            master table, upon rotation to expand, we want to pop this view controller (to avoid
            master and detail being the same view controller).
        */
        navigationController?.popViewController(animated: true)
    }
}
