//
//  AppDelegate.swift
//  CylinderMenu
//
//  Created by NSSimpleApps on 23.04.15.
//  Copyright (c) 2015 NSSimpleApps. All rights reserved.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.black]
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = UINavigationController(rootViewController: CollectionViewController(array: [0, 1, 2, 3, 4]))
        self.window = window
        window.makeKeyAndVisible()
        
        return true
    }
}

