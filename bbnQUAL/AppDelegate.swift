//
//  AppDelegate.swift
//  bbnQUAL
//
//  Created by Dylan Hanson on 11/25/19.
//  Copyright © 2019 Jovialis. All rights reserved.
//

import Foundation
import Firebase
import UIKit
import GTMAppAuth
import AppAuth
import FirebaseAuth

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var currentAuthorizationFlow: OIDExternalUserAgentSession?
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
				
		// Load iPadOS Google Firebase hook, otherwise load macOS
		var optionsPath: String!
		
		if Bundle.main.bundleIdentifier == "dev.jovialis.bbnQUAL" {
			optionsPath = Bundle.main.path(forResource: "iPadOS-GoogleService-Info", ofType: "plist")
		} else {
			optionsPath = Bundle.main.path(forResource: "macOS-GoogleService-Info", ofType: "plist")
		}
		
		let options: FirebaseOptions = FirebaseOptions(contentsOfFile: optionsPath)!
		FirebaseApp.configure(options: options)
		
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
	
	func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        // Sends the URL to the current authorization flow (if any) which will process it if it relates to
        // an authorization response.
		if let flow = self.currentAuthorizationFlow, flow.resumeExternalUserAgentFlow(with: url) {
			self.currentAuthorizationFlow = nil
			return true
		}
		
        // Your additional URL handling (if any) goes here.
        return false
    }


}

