//
//  AppDelegate.swift
//  OdontocetiSwift5
//
//  Created by nativ levy on 13/08/2019.
//  Copyright © 2019 TraxRetail. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions
        launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // Set up the tab bar and it's view controllers.
        let sensorsViewController = SensorsViewController()
        let cartographerViewController = CartographerViewController()
        let mapViewController = MapViewController()
        let tabBarController = UITabBarController()
        tabBarController.setViewControllers([cartographerViewController,
                                             mapViewController,
                                             sensorsViewController], animated: false)
        
        // Initialize the sensor model singletons.
        _ = MagnetModel.sharedModel
        _ = MotionModel.sharedModel
        _ = OrientationModel.sharedModel
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
        
        return true
    }
}

