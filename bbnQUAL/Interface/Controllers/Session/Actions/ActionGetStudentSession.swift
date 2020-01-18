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

class ActionGetStudentSession: Action<(session: DocumentReference, course: CourseOverview, team: TeamOverview)?> {
	
	override func execute() -> Signal<(session: DocumentReference, course: CourseOverview, team: TeamOverview)?> {
		// Grab callback from super
		let callback = super.execute()
		
		// Query function
		self.performQuery(callback: callback)
		
		return callback
	}
	
	private func performQuery(callback: Signal<(session: DocumentReference, course: CourseOverview, team: TeamOverview)?>) {
		// Trigger getSession function
		let functionRef = Functions.functions().httpsCallable("getSession")
		functionRef.call { (result: HTTPSCallableResult?, error: Error?) in
			if let result = result {
				// Convert result to JSON
				let json = JSONObject(result.data)

				// Extract session path individually
				guard let sessionPath = json["sessionPath"].string else {
					print("Course not in session.")
					
					callback.fire(nil)
					return
				}
				
				// Extract path variables
				guard
					let course = CourseOverview(json: json["course"]),
					let team = TeamOverview(json: json["team"])
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
