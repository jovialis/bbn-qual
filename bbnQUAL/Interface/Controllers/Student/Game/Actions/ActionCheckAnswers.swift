//
//  ActionCheckAnswers.swift
//  bbnQUAL
//
//  Created by Dylan Hanson on 12/27/19.
//  Copyright © 2019 Jovialis. All rights reserved.
//

import Foundation
import FirebaseFunctions
import SwiftyJSON
import Signals

class ActionCheckAnswers: Action<AnswerCheckResult?> {
	
	private let answers: [Reagent]
	
	init(answers: [Reagent]) {
		self.answers = answers
	}
	
	override func execute() -> Signal<AnswerCheckResult?> {
		// Grab signal from parent
		let callback = super.execute()
		
		// Get the current reagent group
		let function = Functions.functions().httpsCallable("checkAnswers")
		function.call(
			[
				"answers": self.answers.map { $0.name }
			]) { (result: HTTPSCallableResult?, error: Error?) in
				
			if let result = result {
				
				// Extract data
				do {
					let json = JSON(result.data)
										
					// Pull out progression from JSON
					guard let checkResult = AnswerCheckResult(json) else {
						throw "Invalid arguments prevented acceptance of checkAnswers"
					}
					
					callback.fire(checkResult)
				} catch {
					print(error)
					callback.fire(nil)
				}
				
			} else {
				print(error!)
				callback.fire(nil)
			}
				
		}

		return callback
	}
	
}

enum AnswerCheckResult {
	
	case correct(Int)
	case incorrect(Int)
	case frozen(String)
	
	case finished
	
	case formattingError
	
	init?(_ json: JSON) {		
		guard let result = json["result"].string else {
			return nil
		}
		
		switch result {
		case "correct":
			guard let attempts = json["groupAttempts"].int else {
				return nil
			}
			
			self = .correct(attempts)
			
		case "incorrect":
			guard let attempts = json["attemptsRemaining"].int else {
				return nil
			}
			
			self = .incorrect(attempts)
			
		case "frozen":
			guard let code = json["icebergRef"].string else {
				return nil
			}
			
			self = .frozen(code)
			return
			
		case "finished":
			self = .finished
			
		default:
			return nil
		}
	}
	
}
