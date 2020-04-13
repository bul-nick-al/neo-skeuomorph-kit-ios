//
//  MasterViewController.swift
//  NeoSkeuomorphKit_Example
//
//  Created by Николай Булдаков on 22.02.2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import NeoSkeuomorphKit

class ComponentsTableViewController: UITableViewController {

    var savedSelectionIndexPath: IndexPath?

    struct Example {
        var title: String
        var subTitle: String
        var viewControllerType: UIViewController.Type
    }

    var exampleList = [
        // This is a list of examples offered by this sample.
        Example(title: "ContainerView",
                subTitle: "Example of a container view",
                viewControllerType: ContainerDemonstrationViewController.self
        ),
        Example(title: "Switch",
                subTitle: "Example of a switch",
                viewControllerType: SwitchDemonstrationViewController.self
        )
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.delegate = self  // So we can listen when we come and go on the nav stack.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateCells(_:)),
                                               name: UIViewController.showDetailTargetDidChangeNotification,
                                               object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
    }

    @objc func updateCells(_: Notification) {
        // Whenever the target for showDetailViewController changes, update all of our cells
        // to ensure they have the right accessory type.
        for cell in self.tableView.visibleCells {
            guard let indexPath = self.tableView.indexPath(for: cell) else { continue }
            self.tableView(self.tableView, willDisplay: cell, forRowAt: indexPath)
        }
    }

// MARK: Utility functions
    private func splitViewWantsToShowDetail() -> Bool {
        return splitViewController?.traitCollection.horizontalSizeClass == .regular
    }
}

// MARK: - Table view data source

extension ComponentsTableViewController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exampleList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let componentCell: UITableViewCell
        let reusableIdentifier = "component-cell"

        if let cell = tableView.dequeueReusableCell(withIdentifier: reusableIdentifier) {
            componentCell = cell
        } else {
            componentCell = UITableViewCell(style: .subtitle, reuseIdentifier: reusableIdentifier)
        }

        let example = exampleList[indexPath.row]

        componentCell.textLabel?.text = example.title
        componentCell.detailTextLabel?.text = example.subTitle

        return componentCell
    }
}

// MARK: - UITableViewDelegate
extension ComponentsTableViewController {

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell,
                            forRowAt indexPath: IndexPath) {
        if splitViewWantsToShowDetail() {
            cell.accessoryType = .none
            if let savedSelectionIndexPath = savedSelectionIndexPath {
                self.tableView.selectRow(at: savedSelectionIndexPath, animated: true, scrollPosition: .none)
            }
        } else {
            cell.accessoryType = .disclosureIndicator
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        savedSelectionIndexPath = indexPath

        let example = exampleList[indexPath.row]
        let viewController = example.viewControllerType.init()

        splitViewController?.showDetailViewController(viewController, sender: viewController)
    }
}

// MARK: - UINavigationControllerDelegate

extension ComponentsTableViewController: UINavigationControllerDelegate {

    func navigationController(_ navigationController: UINavigationController,
                              didShow viewController: UIViewController, animated: Bool) {

        if viewController == self {
            // We re-appeared on the nav stack (likely because we manually popped)
            //so our saved selection should be cleared.
            savedSelectionIndexPath = nil
        }
    }
}
