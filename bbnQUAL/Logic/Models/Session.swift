//
//  Session.swift
//  bbnQUAL
//
//  Created by Dylan Hanson on 1/5/20.
//  Copyright © 2020 Jovialis. All rights reserved.
//

import Foundation
import Firebase

struct CourseSession {
	
	let ref: DocumentReference
	let expired: Bool
	let timestamp: Date
	let expiration: Date
	let teacherRef: DocumentReference
	let courseRef: DocumentReference
	
	init?(ref: DocumentReference, json: JSONObject) {
		guard let expired = json["expired"].bool else {
			return nil
		}
		
		guard let timestamp = json["timestamp"].raw as? Timestamp else {
			return nil
		}
		
		guard let expiration = json["expiration"].raw as? Timestamp else {
			return nil
		}
		
		guard let teacherRef = json["teacherRef"].raw as? DocumentReference else {
			return nil
		}
		
		guard let courseRef = json["courseRef"].raw as? DocumentReference else {
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
