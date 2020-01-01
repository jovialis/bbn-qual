//
//  ActionGetUserAccess.swift
//  bbnQUAL
//
//  Created by Dylan Hanson on 1/1/20.
//  Copyright © 2020 Jovialis. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import Signals

class ActionGetUserAccess: ControllerAction<Int> {
	
	private var user: User
	
	init(controller: UIViewController, user: User) {
		self.user = user
		super.init(controller: controller)
	}
	
	override func execute() -> Signal<Int> {
		// Retrieve empty signal from super
		let signal = super.execute()
		
		// Query firestore
		queryFirestore(callback: signal)
		
		return signal
	}
	
	private func queryFirestore(callback: Signal<Int>) {
		// Obtain access level by querying Firebase for user document
		let userRef = Firestore.firestore().collection("users").document(user.uid)
		userRef.getDocument { (snapshot: DocumentSnapshot?, error: Error?) in
			if let snapshot = snapshot {
				let data = snapshot.data()
				
				// Extract access
				let access = (data?["access"] as? Int) ?? 0
				
				// Return successful data
				callback.fire(access)
			} else {
				// Handle Firebase error
				print(error!)
				
				// Retry controller
				self.controller.present(ErrorRetryController {
					
					// On retry pressed, attempt to query again
					self.queryFirestore(callback: callback)
					
				}, animated: true, completion: nil)
			}
		}
	}
	
}
