//
//  MasterViewController.swift
//  NeoSkeuomorphKit_Example
//
//  Created by Николай Булдаков on 22.02.2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import NeoSkeuomorphKit

class MasterViewController: UITableViewController {
    var savedSelectionIndexPath: IndexPath?
    private var detailTargetChange: NSObjectProtocol!

    struct Example {
        var title: String
        var subTitle: String
        var viewcontroller: UIViewController.Type
    }

    var exampleList = [
        // This is a list of examples offered by this sample.
        Example(title: "Container View", subTitle: "ContainerViewController", viewcontroller: TestView.self)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.delegate = self  // So we can listen when we come and go on the nav stack.

        detailTargetChange = NotificationCenter.default.addObserver(
            forName: UIViewController.showDetailTargetDidChangeNotification,
            object: nil,
            queue: OperationQueue.main) { [weak self] (_) in
                // Whenever the target for showDetailViewController changes, update all of our cells
                // to ensure they have the right accessory type.
                //
                guard let self = self else { return }

                for cell in self.tableView.visibleCells {
                    let indexPath = self.tableView.indexPath(for: cell)
                    self.tableView.delegate?.tableView!(self.tableView, willDisplay: cell, forRowAt: indexPath!)
                }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    // MARK: Utility functions

    func splitViewWantsToShowDetail() -> Bool {
        return splitViewController?.traitCollection.horizontalSizeClass == .regular
    }

    func pushOrPresentViewController(viewController: UIViewController, cellIndexPath: IndexPath) {
        if splitViewWantsToShowDetail() {
            let navVC = UINavigationController(rootViewController: viewController)
            splitViewController?.showDetailViewController(navVC, sender: navVC)
            // Replace the detail view controller.
        } else {
            navigationController?.pushViewController(viewController, animated: true) // Just push instead of replace.
        }
    }
}

// MARK: - Table view data source

extension MasterViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return exampleList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let example = exampleList[indexPath.row]
        cell.textLabel?.text = example.title
        cell.detailTextLabel?.text = example.subTitle
        return cell
    }
}

// MARK: - UITableViewDelegate
extension MasterViewController {
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell,
                            forRowAt indexPath: IndexPath) {
        if splitViewWantsToShowDetail() {
            cell.accessoryType = .none
            if self.savedSelectionIndexPath != nil {
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
        pushOrPresentViewController(viewController: example.viewcontroller.init(), cellIndexPath: indexPath)
    }
}

// MARK: - UINavigationControllerDelegate

extension MasterViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController,
                              didShow viewController: UIViewController, animated: Bool) {
        if viewController == self {
            // We re-appeared on the nav stack (likely because we manually popped)
            //so our saved selection should be cleared.
            savedSelectionIndexPath = nil
        }
    }
}
