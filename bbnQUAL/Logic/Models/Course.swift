//
//  Course.swift
//  bbnQUAL
//
//  Created by Dylan Hanson on 1/1/20.
//  Copyright © 2020 Jovialis. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Course {
	
	let name: String
	let settings: CourseSettings
	
	init?(json: JSON) {
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

struct CourseSettings {
	
	let beginnerGroup: Bool
	let attemptsAfterFreeze: Int
	let attemptsBeforeFreeze: Int
	let numChallengeGroups: Int
	let numRegularGroups: Int
	
	init?(json: JSON) {
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
