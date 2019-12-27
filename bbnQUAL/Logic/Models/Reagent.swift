//
//  Reagent.swift
//  bbnQUAL
//
//  Created by Dylan Hanson on 12/26/19.
//  Copyright © 2019 Jovialis. All rights reserved.
//

import Foundation
import Bond

struct Reagent: Hashable {
	
	let name: String
	
	init(_ name: String) {
		self.name = name
	}
	
	static func ==(lhs: Reagent, rhs: Reagent) -> Bool {
		return lhs.name == rhs.name
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(self.name)
	}
	
}
