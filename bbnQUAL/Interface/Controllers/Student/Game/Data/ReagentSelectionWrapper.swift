//
//  ReagentSelectionWrapper.swift
//  bbnQUAL
//
//  Created by Dylan Hanson on 12/27/19.
//  Copyright © 2019 Jovialis. All rights reserved.
//

import Foundation
import Bond
import Signals

class EmptyReagentSelectionWrapper: ReagentSelectionWrapper {
	init() {
		super.init(reagents: [])
	}
}

class ReagentSelectionWrapper {
	
	let reagents: [Reagent]
	
	// Instantiate an observable array with the same number of items as the reagents list
	private var indexedReagents: [Reagent?]
	let indexedReagentsChanged = Signal<[Reagent?]>()
	
	init(reagents: [Reagent]) {
		self.reagents = reagents
		self.indexedReagents = [Reagent?].init(repeating: nil, count: reagents.count)
	}
	
	// Fire signal
	private func notify() {
		self.indexedReagentsChanged.fire(self.indexedReagents)
	}
	
	// Valid reagent
	private func valid(_ reagent: Reagent) -> Bool {
		return self.reagents.contains(reagent)
	}
	
	// Valid index
	private func valid(_ index: Int) -> Bool {
		return index >= 0 && index < self.reagents.count
	}
	
	func isSelected(_ reagent: Reagent) -> Bool {
		return self.indexedReagents.contains(reagent)
	}
	
	func isAtIndex(_ reagent: Reagent, index: Int) -> Bool {
		return self.indexedReagents[index] == reagent
	}
	
	func indexEmpty(_ index: Int) -> Bool {
		return self.indexedReagents[index] == nil
	}
	
	func occupier(_ index: Int) -> Reagent? {
		return self.indexedReagents[index]
	}
	
	func getIndex(_ reagent: Reagent) -> Int? {
		return self.indexedReagents.firstIndex(of: reagent)
	}
	
	func setIndex(_ reagent: Reagent, index: Int?) {
		if index == nil {
			// We're unselecting
			// Only need to make changes if it's actually selected now
			unselect(reagent)
		} else {
			let index: Int = index!
			
			// If it's selected already, we need to unselect it
			unselect(reagent)
			
			// If there's something at the given index, we need to unselect it
			unselect(index)
			
			self.indexedReagents[index] = reagent
			
			// Update handlers of the change
			self.notify()
		}
	}
	
	func unselect(_ reagent: Reagent) {
		if isSelected(reagent) {
			let curIndex = self.getIndex(reagent)!
			self.unselect(curIndex)
		}
	}
	
	func unselect(_ index: Int) {
		if !indexEmpty(index) {
			self.indexedReagents[index] = nil
			
			// Update observers
			self.notify()
		}
	}
	
	func validateDataStructuring() -> Bool {
		// Don't allow empty reagent sets 
		if self.reagents.isEmpty {
			return false
		}
		
		var used: [Reagent] = []
		for item in self.indexedReagents {
			if item == nil || !self.reagents.contains(item!) || used.contains(item!) {
				return false
			}
			used.append(item!)
		}
		return true
	}
	
	func checkAnswers() -> Signal<AnswerCheckResult?> {
		// Ensure proper data curation
		if self.validateDataStructuring() {
			
			// Checker with a flattened indexedReagents array
			let checker = ActionCheckAnswers(
				answers: self.indexedReagents.compactMap { $0 }
			)
			
			return checker.execute()
		}
		
		// Create a signal to return a nonanswer
		let signal = Signal<AnswerCheckResult?>()
		signal.fire(.formattingError)
		
		return signal
	}

}
