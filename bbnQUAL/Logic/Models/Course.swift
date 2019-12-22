//
//  Course.swift
//  bbnQUAL
//
//  Created by Dylan Hanson on 12/14/19.
//  Copyright © 2019 Jovialis. All rights reserved.
//

import Foundation
import FirebaseFirestoreSwift
import Firebase

class Course: FirestoreRepresentable {
	
    // Save a Handler
    lazy private(set) var handler: FirestoreRepresentableHandler = FirestoreRepresentableHandler(represented: self)
    
    var name: String = ""
	var archived: Bool = false
    
    let collection = ""
    let uid: String
    
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
    
    // Update using Firebase data
    func update(map: [String: Any]) throws {
        guard let name = map["name"] as? String else {
            throw QError.insufficientData
        }
           
        guard let archived = map["archived"] as? Bool else {
            throw QError.insufficientData
        }
           
        self.name = name
        self.archived = archived
	}
    
    // Convert back to map for saving in Firebase
    var mapped: [String: Any] {
        return [
            "name": self.name,
            "archived": self.archived
        ]
    }
	
}
