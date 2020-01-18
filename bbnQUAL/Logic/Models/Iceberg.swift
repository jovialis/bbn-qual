//
//  Iceberg.swift
//  bbnQUAL
//
//  Created by Dylan Hanson on 1/16/20.
//  Copyright © 2020 Jovialis. All rights reserved.
//

import Foundation
import Firebase

struct Iceberg {
	
	let ref: DocumentReference
	let courseRef: DocumentReference
	let team: Team
	let progressionRef: DocumentReference
	let reagentGroup: String
	let timestamp: Timestamp
	
	init?(ref: DocumentReference, json: JSONObject) {
		guard let courseRef = (json["courseRef"].raw as? DocumentReference) else {
			return nil
		}
		
		guard let teamRef = json["team"]["ref"].raw as? DocumentReference else {
			return nil
		}
		
		guard let team = Team(reference: teamRef, json: json["team"]) else {
			return nil
		}
		
		guard let progressionRef = json["progressionRef"].raw as? DocumentReference else {
			return nil
		}
		
		guard let reagentGroup = json["reagentGroup"].string else {
			return nil
		}
		
		guard let timestamp = json["timestamp"].raw as? Timestamp else {
			return nil
		}
		
		self.ref = ref
		self.courseRef = courseRef
		self.team = team
		self.progressionRef = progressionRef
		self.reagentGroup = reagentGroup
		self.timestamp = timestamp
	}
	
}
