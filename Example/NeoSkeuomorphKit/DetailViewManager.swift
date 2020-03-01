//
//  DetailViewManager.swift
//  NeoSkeuomorphKit_Example
//
//  Created by Николай Булдаков on 23.02.2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

class DetailViewManager: NSObject, UISplitViewControllerDelegate {

    @IBOutlet weak var splitViewController: UISplitViewController! {
        didSet {
            splitViewController?.preferredDisplayMode = .allVisible
        }
    }

    /// Swaps out the detail for view controller for the Split View Controller this instance is managing.
     func set(detailViewController: UIViewController) {
        var viewControllers = splitViewController.viewControllers

        if viewControllers.count > 1 {
            viewControllers[1] = detailViewController
        }

        splitViewController?.viewControllers = viewControllers
    }

    // MARK: - UISplitViewControllerDelegate

    func splitViewController(_ splitViewController: UISplitViewController,
                             collapseSecondary secondaryViewController: UIViewController,
                             onto primaryViewController: UIViewController) -> Bool {
        return true
    }

    func splitViewController(_ splitViewController: UISplitViewController,
                             separateSecondaryFrom primaryViewController: UIViewController) -> UIViewController? {
        var returnSecondaryViewController: UIViewController?

        guard let primaryViewController = primaryViewController as? UINavigationController,
            let navigationViewController = primaryViewController.topViewController as? UINavigationController else {
            return nil
        }

        let currentViewController = navigationViewController.visibleViewController

        if currentViewController?.popDueToSizeChange != nil {
            currentViewController?.popDueToSizeChange()
        }

        // The currentVC has popped, now obtain it's ancestor vc in the table.
        let currentViewController2 = navigationViewController.visibleViewController

        if currentViewController2 is ComponentsTableViewController {
            let baseTableViewViewController = currentViewController2 as? ComponentsTableViewController

            if baseTableViewViewController?.tableView.indexPathForSelectedRow == nil {
                // The table has no selection, make the detail empty.
                returnSecondaryViewController = splitViewController.storyboard?
                    .instantiateViewController(withIdentifier: Constants.defaultControllerName)
            }
        }

        return returnSecondaryViewController
    }
}
