//
//  ActionGetSessionContent.swift
//  bbnQUAL
//
//  Created by Dylan Hanson on 1/5/20.
//  Copyright © 2020 Jovialis. All rights reserved.
//

import Foundation
import Firebase
import Signals

class ActionGetSessionContent: Action<Callback<CourseSession>> {
	
	private let sessionRef: DocumentReference
	
	init(sessionRef: DocumentReference) {
		self.sessionRef = sessionRef
	}
	
	override func execute() -> Signal<Callback<CourseSession>> {
		let callback = super.execute()
		
		// Obtain data
		self.sessionRef.getDocument { (snapshot: DocumentSnapshot?, error: Error?) in
			if let snapshot = snapshot {
				// Unwrap data since we know the document isn't null
				let data = snapshot.data()!
				
				if let course = CourseSession(ref: self.sessionRef, data: data) {
					callback.fire(.success(object: course))
				} else {
					callback.fire(.failure(error: "Could not parse Session"))
				}
			} else {
				callback.fire(.failure(error: error!))
			}
		}

		
		return callback
	}
	
}
