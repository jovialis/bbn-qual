//
//  Map+JSON.swift
//  bbnQUAL
//
//  Created by Dylan Hanson on 1/17/20.
//  Copyright © 2020 Jovialis. All rights reserved.
//

import Foundation

struct JSONObject {
	
	private let val: Any?
	
	init(_ val: Any?) {
		self.val = val
	}
	
	subscript(index: String) -> JSONObject {
		get {
			guard let map = self.val as? [String: Any] else {
				return JSONObject(nil)
			}
			
			return JSONObject(map[index])
		}
	}
	
	var array: [JSONObject]? {
		guard let values = self.val as? [Any] else {
			return nil
		}
		
		return values.map { JSONObject($0) }
	}
	
	var arrayValue: [JSONObject] {
		return self.array ?? []
	}
	
	var exists: Bool {
		return self.val != nil
	}
	
}

extension JSONObject {
	
	var bool: Bool? {
		return self.val as? Bool
	}
	
	var boolValue: Bool {
		return self.bool ?? false
	}
	
	var string: String? {
		return self.val as? String
	}
	
	var stringValue: String {
		return self.string ?? ""
	}
	
	var int: Int? {
		return self.val as? Int
	}
	
	var intValue: Int {
		return self.int ?? -1
	}
	
	var double: Double? {
		return self.val as? Double
	}
	
	var doubleValue: Double {
		return self.double ?? -1
	}
	
	var raw: Any? {
		return self.val
	}
	
}
