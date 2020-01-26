//
//  TeacherProgressionOverview.swift
//  bbnQUAL
//
//  Created by Dylan Hanson on 1/17/20.
//  Copyright © 2020 Jovialis. All rights reserved.
//

import Foundation
import Firebase

// Represents a teacher view of a given group's progression through QUAL
struct TeacherProgressionOverview {
	
	let ref: DocumentReference
	let completed: TeacherProgressionCompleted
	let current: TeacherProgressionCurrent?
	
	let name: String
	let members: [TeamMember]
	
	let totalAttempts: Int
	let finished: Bool
	
	init?(ref: DocumentReference, json: JSONObject) {
		guard let completed = TeacherProgressionCompleted(json: json["completed"]) else {
			return nil
		}
		
		let current = TeacherProgressionCurrent(json: json["current"])
		
		guard let attempts = json["totalAttempts"].int else {
			return nil
		}
		
		guard let finished = json["finished"].bool else {
			return nil
		}
		
		guard let membersJSON = json["memberRefs"].array else {
			return nil
		}
		
		guard let name = json["name"].string else {
			return nil
		}
		
		self.name = name
		self.members = membersJSON.compactMap { TeamMember(json: $0) }
		
		self.ref = ref
		self.completed = completed
		self.current = current
		
		self.totalAttempts = attempts
		self.finished = finished
	}
	
	// All assigned regular groups, including current
	var allAssignedRegular: [String] {
		var array = self.completed.regular
		
		if let current = self.current, current.difficulty == .regular {
			array.append(current.reagentGroup)
		}
		
		return array
	}
	
	// All assigned challenge groups, including current
	var allAssignedChallenge: [String] {
		var array = self.completed.challenge
		
		if let current = self.current, current.difficulty == .challenge {
			array.append(current.reagentGroup)
		}
		
		return array
	}
	
}

struct TeacherProgressionCompleted {
	
	let beginner: Bool
	let regular: [String]
	let challenge: [String]
	
	init?(json: JSONObject) {
		guard let beginner = json["beginner"].bool else {
			return nil
		}
		
		guard let regularJSON = json["regular"].array else {
			return nil
		}
		
		let regular = regularJSON.compactMap { $0.string }
		
		guard let challengeJSON = json["challenge"].array else {
			return nil
		}
		
		let challenge = challengeJSON.compactMap { $0.string }
		
		self.beginner = beginner
		self.regular = regular
		self.challenge = challenge
	}
	
}

struct TeacherProgressionCurrent {
	
	let reagentGroup: String
	let reagentGroupAttempts: Int
	let difficulty: ProgressionDifficulty

	let reagents: [String]
	let correctReagentOrder: [String]
	
	let frozen: Bool
	let attemptsRemaining: Int
	
	init?(json: JSONObject) {
		guard let reagentGroup = json["group"].string else {
			return nil
		}
		
		guard let reagentGroupAttempts = json["groupAttempts"].int else {
			return nil
		}
		
		guard let difficulty = ProgressionDifficulty(val: json["difficulty"].int ?? -1) else {
			return nil
		}
		
		guard let reagentsJSON = json["reagents"].array else {
			return nil
		}
		
		let reagents = reagentsJSON.compactMap { $0.string }
		
		guard let reagentsAnswerJSON = json["answers"].array else {
			return nil
		}
		
		let reagentsAnswers = reagentsAnswerJSON.compactMap { $0.string }
		
		guard let frozen = json["frozen"].bool else {
			return nil
		}
		
		guard let attemptsLeft = json["attemptsRemaining"].int else {
			return nil
		}
		
		self.reagentGroup = reagentGroup
		self.reagentGroupAttempts = reagentGroupAttempts
		self.difficulty = difficulty
		self.reagents = reagents
		self.correctReagentOrder = reagentsAnswers
		self.frozen = frozen
		self.attemptsRemaining = attemptsLeft
	}
	
}
