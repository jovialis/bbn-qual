//
//  ActionGetClassSession.swift
//  bbnQUAL
//
//  Created by Dylan Hanson on 1/3/20.
//  Copyright © 2020 Jovialis. All rights reserved.
//

import Foundation
import Signals
import Firebase

class ActionGetClassSession: Action<Callback<DocumentReference?>> {
	
	private let courseRef: DocumentReference
	
	init(course: DocumentReference) {
		self.courseRef = course
	}
	
	override func execute() -> Signal<Callback<DocumentReference?>> {
		// Grab callback from super
		let callback = super.execute()
		
		// Query function
		self.performQuery(callback: callback)
		
		return callback
	}
	
	private func performQuery(callback: Signal<Callback<DocumentReference?>>) {
		// Trigger getSession function
		let functionRef = Functions.functions().httpsCallable("getClassSession")
		functionRef.call([
			
			// Trigger endpoint with course reference
			"coursePath": self.courseRef.path
			
		]) { (result: HTTPSCallableResult?, error: Error?) in
			
			if let result = result {
				// Convert result to JSON
				let json = JSONObject(result.data)

				// Extract session path
				guard let sessionPath = json["sessionPath"].string else {
					callback.fire(.success(object: nil))
					return
				}
				
				let sessionRef = Firestore.firestore().document(sessionPath)
				callback.fire(.success(object: sessionRef))
			} else {
				print(error!)
				
				// Trigger with no document reference
				callback.fire(.failure(error: error!))
			}
			
		}
	}
	
}
