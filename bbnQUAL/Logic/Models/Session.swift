//
//  Session.swift
//  bbnQUAL
//
//  Created by Dylan Hanson on 1/5/20.
//  Copyright © 2020 Jovialis. All rights reserved.
//

import Foundation
import SwiftyJSON
import Firebase

struct CourseSession {
	
	let ref: DocumentReference
	let expired: Bool
	let timestamp: Date
	let expiration: Date
	let teacherRef: DocumentReference
	let courseRef: DocumentReference
	
	init?(ref: DocumentReference, data: [String: Any]) {		
		guard let expired = data["expired"] as? Bool else {
			return nil
		}
		
		guard let timestamp = data["timestamp"] as? Timestamp else {
			return nil
		}
		
		guard let expiration = data["expiration"] as? Timestamp else {
			return nil
		}
		
		guard let teacherRef = data["teacherRef"] as? DocumentReference else {
			return nil
		}
		
		guard let courseRef = data["courseRef"] as? DocumentReference else {
			return nil
		}
		
		self.ref = ref
		self.expired = expired
		self.timestamp = timestamp.dateValue()
		self.expiration = expiration.dateValue()
		self.teacherRef = teacherRef
		self.courseRef = courseRef
	}
	
}
