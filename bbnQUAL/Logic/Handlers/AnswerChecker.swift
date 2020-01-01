//
//  AnswerChecker.swift
//  bbnQUAL
//
//  Created by Dylan Hanson on 12/27/19.
//  Copyright © 2019 Jovialis. All rights reserved.
//

import Foundation
import FirebaseFunctions
import SwiftyJSON

final class AnswerChecker {
	
	private let answers: [Reagent]
	
	init(answers: [Reagent]) {
		self.answers = answers
	}
	
	func check() -> CallbackSignal<AnswerCheckResult> {
		// Signal
		let signal = CallbackSignal<AnswerCheckResult>()
		
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
					
					print(json)
					
					// Pull out progression from JSON
					guard let checkResult = AnswerCheckResult(json) else {
						throw "Invalid arguments prevented acceptance of checkAnswers"
					}
					
					signal.fire(.success(object: checkResult))
				} catch {
					signal.fire(.failure(error: error))
				}
				
			} else {
				signal.fire(.failure(error: error!))
			}
				
		}
		
		return signal

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
