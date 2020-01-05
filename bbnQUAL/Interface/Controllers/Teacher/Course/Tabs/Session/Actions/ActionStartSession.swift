//
//  ActionStartSession.swift
//  bbnQUAL
//
//  Created by Dylan Hanson on 1/5/20.
//  Copyright © 2020 Jovialis. All rights reserved.
//

import Foundation
import Firebase
import Signals

class ActionStartSession: Action<Callback<CourseSession>> {
	
	private let courseRef: DocumentReference
	private let duration: Int
	
	init(courseRef: DocumentReference, duration: Int = 60) {
		self.courseRef = courseRef
		self.duration = duration
	}
	
	override func execute() -> Signal<Callback<CourseSession>> {
		// Grab callback frmo super
		let callback = super.execute()
		
		// Trigger remote method
		let functionRef = Functions.functions().httpsCallable("startSession")
		functionRef.call([
			
			"courseId": self.courseRef.documentID,
			"duration": self.duration
			
		]) { (result: HTTPSCallableResult?, error: Error?) in
			
			if let result = result {
				let data = result.data as! [String: Any]
				
				// If it was successful, extract session
				if let sessionPath = data["sessionPath"] as? String {
					let sessionRef = Firestore.firestore().document(sessionPath)
										
					// Parse
					if let session = CourseSession(ref: sessionRef, data: (data["session"] as? [String: Any]) ?? [:]) {
						// Update observer
						callback.fire(.success(object: session))
					} else {
						callback.fire(.failure(error: "Could not parse Session"))
					}
				}
				
			} else {
				callback.fire(.failure(error: error!))
			}
			
		}

		return callback
	}

}
