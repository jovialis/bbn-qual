//
//  Progression.swift
//  bbnQUAL
//
//  Created by Dylan Hanson on 12/27/19.
//  Copyright © 2019 Jovialis. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Progression {
	
	let status: ProgressionStatus
	let progress: ProgressionProgress

	init?(json: JSON) {
		guard let status = ProgressionStatus(json: json) else {
			return nil
		}
		
		guard let progress = ProgressionProgress(json: json["progress"]) else {
			return nil
		}
		
		self.status = status
		self.progress = progress
	}
	
}

struct ProgressionProgress {
	
	let beginner: ProgressionTrackProgress
	let regular: ProgressionTrackProgress
	let challenge: ProgressionTrackProgress
	
	init?(json: JSON) {
		guard
			let beginner = ProgressionTrackProgress(json: json["beginner"]),
			let regular = ProgressionTrackProgress(json: json["regular"]),
			let challenge = ProgressionTrackProgress(json: json["challenge"]) else {
				return nil
		}
			
		self.beginner = beginner
		self.regular = regular
		self.challenge = challenge
	}
	
	func forDifficulty(_ difficulty: ProgressionDifficulty) -> ProgressionTrackProgress {
		switch difficulty {
		case .practice:
			return self.beginner
		case .regular:
			return self.regular
		case .challenge:
			return self.challenge
		}
	}
	
}

struct ProgressionTrackProgress {
	
	let completed: Int
	let required: Int
	
	init?(json: JSON) {
		guard let completed = json["completed"].int, let required = json["required"].int else {
			return nil
		}
		
		self.completed = completed
		self.required = required
	}
	
}

enum ProgressionStatus {
	
	case active(String, ProgressionDifficulty, Int, [Reagent])
	case frozen(String)
	case finished
	
}


enum ProgressionDifficulty {
	
	case practice
	case regular
	case challenge
	
}

extension ProgressionStatus {
	
	init?(json: JSON) {
		switch json["status"].stringValue {
		case "finished":
			self = .finished
			return
		case "frozen":
			guard let code = json["icebergRef"].string else {
				return nil
			}
			
			self = .frozen(code)
			return
		case "active":
			// Continue parse
			break

		default:
			// Broken
			return nil
		}
		
		let prefix = json["prefix"].string
		let difficulty = ProgressionDifficulty(val: json["difficulty"].int ?? -1)
		let attempts = json["attemptsRemaining"].int
		let reagents = json["reagents"].array
		
		if prefix == nil || difficulty == nil || attempts == nil || reagents == nil {
			return nil
		}
		
		let reagentsList = reagents!.map{ Reagent($0.stringValue) }
		
		self = .active(prefix!, difficulty!, attempts!, reagentsList)
	}
	
}

extension ProgressionDifficulty {
	
	init?(val: Int) {
		switch val {
		case 0:
			self = .practice
		case 1:
			self = .regular
		case 2:
			self = .challenge
		default:
			return nil
		}
	}
	
	var displayName: String {
		switch self {
		case .practice:
			return "Practice"
		case .regular:
			return "Regular"
		case .challenge:
			return "Challenge"
		}
	}
	
}
