//
//  AppDelegate.swift
//  NeoSkeuomorphKit
//
//  Created by Nikolay on 12/14/2019.
//  Copyright (c) 2019 Nikolay. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    /** The detailViewManager is responsible for maintaining the UISplitViewController delegation
        and for managing the detail view controller of the split view.
    */
    var detailViewManager = DetailViewManager()

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if let splitViewController = window!.rootViewController as? UISplitViewController {
            splitViewController.preferredDisplayMode = .allVisible
            splitViewController.delegate = detailViewManager
            detailViewManager.splitViewController = splitViewController

            // Set the master view controller table view with translucent background.
            if #available(iOS 13.0, *) {
                splitViewController.primaryBackgroundStyle = .sidebar
            } else {
                // Fallback on earlier versions
            }
        }

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {

    }

    func applicationDidEnterBackground(_ application: UIApplication) {

    }

    func applicationWillEnterForeground(_ application: UIApplication) {

    }

    func applicationDidBecomeActive(_ application: UIApplication) {

    }

    func applicationWillTerminate(_ application: UIApplication) {

    }

}
