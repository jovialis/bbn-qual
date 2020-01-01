//
//  RootController.swift
//  bbnQUAL
//
//  Created by Dylan Hanson on 12/31/19.
//  Copyright © 2019 Jovialis. All rights reserved.
//

import Foundation
import Firebase
import UIKit

class RootController: UIViewController {
	
	// This controller is at the very base of the navigation stack.
	// Its primary purpose is to handle navigation to the VC where the
	// main user interaction will actually occur. This means its path will
	// generally look something like:
	//
	// Auth?
	//       No  --> LoginVC
	//       Yes --> Access Level?
	//							   0   --> Student VC
	//							   1/2 --> Teacher VC
	//
	// If the authenticated state changes, RootController will pop
	// back to itself, then reroute the user to the Login VC.
	//
	// If the access level changes, RootController will pop
	// back to itself and reroute the user to the appropriate VC.
	
	var isTopController: Bool { return self.navigationController?.topViewController == self }
	
	// Upon startup
	override func viewDidLoad() {
		super.viewDidLoad()

		self.view.backgroundColor = .systemBackground

		// Disable navigation bar and swipe back action
		self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
		self.navigationController?.isNavigationBarHidden = true
		
		// Logout, clearing cache on startup
		do {
			try Auth.auth().signOut()
		} catch {
			print(error)
		}
		
		// Startups
		// Constantly observe auth state
		self.observeAuthState()
	}
	
	// Observe the state of Firebase auth.
	private func observeAuthState() {
		Auth.auth().addStateDidChangeListener { (auth: Auth, user: User?) in
			// If the auth state updated, we need to pop back to self
			self.popToSelf()
			
			if let user = user {
				// Open user content
				self.pushToContent(user: user)
			} else {
				// If user is null, perform auth
				self.pushToAuth()
			}
		}
	}
	
	private func pushToContent(user: User) {
		print("Progressing to content with user \( user.email! )")
		
		// Call action to get the user's access level
		ActionGetUserAccess(controller: self, user: user).execute().then(listener: self) { (access: Int) in
			
			switch access {
			// 0 = student
			case 0:
				// Push to student session controller
				let controller = StudentSessionController()
				self.navigationController?.pushViewController(controller, animated: false)
				break
				
			// Non 0 = teacher
			default:
				break
			}
			
		}
	}
	
	private func pushToAuth() {
		let controller = AuthController()
		self.navigationController?.pushViewController(controller, animated: false)
	}
	
	// Clear the navigation stack back to self.
	private func popToSelf() {
		if !self.isTopController {
			self.navigationController?.popToViewController(self, animated: false)
		}
	}
	
}
