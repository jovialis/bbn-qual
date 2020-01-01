//
//  ActionGetStudentSession.swift
//  bbnQUAL
//
//  Created by Dylan Hanson on 1/1/20.
//  Copyright © 2020 Jovialis. All rights reserved.
//

import Foundation
import Signals
import Firebase
import SwiftyJSON

class ActionGetStudentSession: ControllerAction<(session: DocumentReference, course: Course, team: Team)?> {
	
	override func execute() -> Signal<(session: DocumentReference, course: Course, team: Team)?> {
		// Grab callback from super
		let callback = super.execute()
		
		// Query function
		self.performQuery(callback: callback)
		
		return callback
	}
	
	private func performQuery(callback: Signal<(session: DocumentReference, course: Course, team: Team)?>) {
		// Trigger getSession function
		let functionRef = Functions.functions().httpsCallable("getSession")
		functionRef.call { (result: HTTPSCallableResult?, error: Error?) in
			if let result = result {
				// Convert result to JSON
				let json = JSON(result.data)

				// Extract session path individually
				guard let sessionPath = json["sessionPath"].string else {
					print("Course not in session.")
					
					callback.fire(nil)
					return
				}
				
				// Extract path variables
				guard
					let course = Course(json: json["course"]),
					let team = Team(json: json["team"])
				else {
					print("Failed to parse session result")
					
					// Trigger with no document ereference
					callback.fire(nil)
					return
				}
				
				// Resolve with parsed document
				let sessionRef = Firestore.firestore().document(sessionPath)
				
				callback.fire((session: sessionRef, course: course, team: team))
			} else {
				print(error!)
				
				// Trigger with no document reference
				callback.fire(nil)
			}
		}
	}
	
}
