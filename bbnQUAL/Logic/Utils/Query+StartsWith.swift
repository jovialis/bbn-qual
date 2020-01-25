//
//  Query+StartsWith.swift
//  bbnQUAL
//
//  Created by Dylan Hanson on 1/25/20.
//  Copyright © 2020 Jovialis. All rights reserved.
//

import Foundation
import Firebase

extension Query {
	
	func whereField(_ field: String, startsWith value: String) -> Query {
		// Lower bounds
		let query = self.whereField(field, isGreaterThanOrEqualTo: value)
		
		// Increment last char of value
		let lastChar = value.last!
		let scalar = lastChar.unicodeScalars.last!
		
		let newScalarValue = scalar.value + 1
		let newScalar = UnicodeScalar(newScalarValue)
		let newLastChar = Character(newScalar!)
		
		var newString = value
		newString.remove(at: newString.indices.last!)
		newString.append(newLastChar)
		
		// Upper bounds
		let queryUpper = query.whereField(field, isLessThan: newString)
		return queryUpper
	}
	
}
