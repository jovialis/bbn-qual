//
//  ActionExtendSession.swift
//  bbnQUAL
//
//  Created by Dylan Hanson on 1/5/20.
//  Copyright © 2020 Jovialis. All rights reserved.
//

import Foundation
import Firebase
import Signals

class ActionExtendSession: Action<Callback<Void>> {
	
	private let session: CourseSession
	private let seconds: Int
	
	init(session: CourseSession, seconds: Int = 5 * 60) {
		self.session = session
		self.seconds = seconds
	}
	
	override func execute() -> Signal<Callback<Void>> {
		// Grab signal
		let callback = super.execute()
		
		// Increase expiration date
		let expiration = self.session.expiration
		let newExpiration = expiration.addingTimeInterval(Double( self.seconds ))
		
		let documentData: [String: Any] = [
			"expiration": Timestamp(date: newExpiration)
		]
		
		// Set document data
		self.session.ref.updateData(documentData) { (error: Error?) in
			if let error = error {
				callback.fire(.failure(error: error))
			} else {
				callback.fire(.success(object: ()))
			}
		}
		
		return callback
	}
	
}
