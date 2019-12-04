//
//  User.swift
//  bbnQUAL
//
//  Created by Dylan Hanson on 11/28/19.
//  Copyright © 2019 Jovialis. All rights reserved.
//

import Foundation
import Signals

class QualUser: FirestoreRepresentable {
		
	lazy private(set) var handler: FirestoreRepresentableHandler = FirestoreRepresentableHandler(represented: self)
	
	let uid: String
    let collection: String = UserManager.collection
	
	// Profile content variables
	var name: String = ""
	var username: String = ""
	var access: Int = 0
    var course: String = ""
		
	var mapped: [String: Any] {
		return [
			"name": self.name,
			"username": self.username,
			"access": self.access,
            "course": self.course
		]
	}
	
    // Default init
    required init(uid: String) {
        self.uid = uid
    }
    
	required init?(uid: String, map: [String: Any] = [:]) {
		self.uid = uid
        
        // Load content
        do {
            try self.update(map: map)
        } catch {
            return nil
        }
	}
	
	func update(map: [String : Any]) throws {
		self.name = (map["name"] as? String) ?? self.name
		self.username = (map["username"] as? String) ?? self.username
		self.access = (map["access"] as? Int) ?? self.access
        self.course = (map["course"] as? String) ?? self.course
	}
	
}

extension QualUser {
    
    var inCourse: Bool {
        return !self.course.isEmpty
    }
    
}
