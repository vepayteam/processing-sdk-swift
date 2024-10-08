//
//  AppDelegate.swift
//  VepaySDKExample
//
//  Created by Bohdan Hrozian on 28.12.2023.
//

import UIKit
import VepaySDK

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let bundle = Bundle.vepaySDK
        let fileNames = ["InterAppeer-SemiBold", "Inter-Regular", "Inter-SemiBold"]
        let urls = fileNames.map ({ bundle.url(forResource: $0, withExtension: "ttf")! })
        urls.forEach { fontURL in
            let fontDataProvider = CGDataProvider(url: fontURL as CFURL)!
            let font = CGFont(fontDataProvider)!
            CTFontManagerRegisterGraphicsFont(font, nil)
        }
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

