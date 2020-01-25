//
//  Course.swift
//  bbnQUAL
//
//  Created by Dylan Hanson on 1/1/20.
//  Copyright © 2020 Jovialis. All rights reserved.
//

import Foundation
import Firebase

protocol CourseSkeleton {
	
	var name: String { get }
	var settings: CourseSettings { get }
	
}

// Simple course struct for maintaining information security.
// Primarily used by StudentSession fetching.
struct CourseOverview: CourseSkeleton {
	
	let name: String
	let settings: CourseSettings
	
	init?(json: JSONObject) {
		guard let name = json["name"].string else {
			return nil
		}
		
		guard let settings = CourseSettings(json: json["settings"]) else {
			return nil
		}
		
		self.name = name
		self.settings = settings
	}
	
}

// Represents a fully downloaded course, grabbed from database queries
// rather than simply from an overview web call
struct Course: CourseSkeleton {
	
	let ref: DocumentReference
	let name: String
	let settings: CourseSettings
	let teachers: [TeamMember]
	let timestamp: Date
	let status: CourseStatus
	
	init?(ref: DocumentReference, json: JSONObject) {
		guard let name = json["name"].string else {
			return nil
		}
		
		guard let statusInt = json["status"].int, let status = CourseStatus(rawValue: statusInt) else {
			return nil
		}
		
		guard let settings = CourseSettings(json: json["settings"]) else {
			return nil
		}
		
		let teachersArray = json["teacherRefs"].arrayValue.compactMap { TeamMember(json: $0) }
		
		guard let timestamp = json["timestamp"].raw as? Timestamp else {
			return nil
		}
		
		self.ref = ref
		self.name = name
		self.status = status
		self.settings = settings
		self.teachers = teachersArray
		self.timestamp = timestamp.dateValue()
	}
	
}

struct CourseSettings {
	
	let beginnerGroup: Bool
	let attemptsAfterFreeze: Int
	let attemptsBeforeFreeze: Int
	let numChallengeGroups: Int
	let numRegularGroups: Int
	
	init?(json: JSONObject) {
		guard let beginnerGroup = json["assignBeginnerGroup"].bool else {
			return nil
		}
		
		guard let attemptsAfterFreeze = json["attemptsAfterFreeze"].int else {
			return nil
		}
		
		guard let attemptsBeforeFreeze = json["attemptsBeforeFreeze"].int else {
			return nil
		}
		
		guard let numChallengeGroups = json["numChallengeGroups"].int else {
			return nil
		}
		
		guard let numRegularGroups = json["numRegularGroups"].int else {
			return nil
		}
		
		self.beginnerGroup = beginnerGroup
		self.attemptsAfterFreeze = attemptsAfterFreeze
		self.attemptsBeforeFreeze = attemptsBeforeFreeze
		self.numChallengeGroups = numChallengeGroups
		self.numRegularGroups = numRegularGroups
	}
	
}

enum CourseStatus: Int {
	
	case setup
	case live
	case archived
	
	var displayName: String {
		switch self {
		case .setup:
			return "Setup"
			
		case .live:
			return "Live"
			
		case .archived:
			return "Archived"
			
		}
	}
	
}
