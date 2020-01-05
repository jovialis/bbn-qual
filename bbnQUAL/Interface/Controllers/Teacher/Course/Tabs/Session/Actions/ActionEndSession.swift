//
//  ActionEndSession.swift
//  bbnQUAL
//
//  Created by Dylan Hanson on 1/5/20.
//  Copyright © 2020 Jovialis. All rights reserved.
//

import Foundation
import Firebase
import Signals

class ActionEndSession: Action<Callback<Void>> {
	
	private let sessionRef: DocumentReference
	private let remainingSeconds: Int?
	
	init(sessionRef: DocumentReference, remainingSeconds: Int? = nil) {
		self.sessionRef = sessionRef
		self.remainingSeconds = remainingSeconds
	}
	
	override func execute() -> Signal<Callback<Void>> {
		// Grab signal
		let callback = super.execute()
		
		var documentData: [String: Any] = [:]
		
		// Set expired flag if remainingSeconds null
		if let remainingSeconds = self.remainingSeconds {
			// Get date to expire in at Now + X seconds
			let expirationDate = Date().addingTimeInterval(Double(remainingSeconds))
			documentData["expiration"] = Timestamp(date: expirationDate)
		} else {
			documentData["expired"] = true
		}
		
		// Set document data
		self.sessionRef.updateData(documentData) { (error: Error?) in
			if let error = error {
				callback.fire(.failure(error: error))
			} else {
				callback.fire(.success(object: ()))
			}
		}
		
		return callback
	}
	
}
