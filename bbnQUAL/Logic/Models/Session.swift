//
//  Session.swift
//  bbnQUAL
//
//  Created by Dylan Hanson on 12/3/19.
//  Copyright © 2019 Jovialis. All rights reserved.
//

import Foundation
import Signals
import Firebase
import FirebaseFirestoreSwift

class QualSession: FirestoreRepresentable {
    
    // Save a Handler
    lazy private(set) var handler: FirestoreRepresentableHandler = FirestoreRepresentableHandler(represented: self)
    
    var course: String = ""
    var teacher: String = ""
    var expired: Bool = false
    var timestamp: Date = Date()
    
    var courseRef: DocumentReference {
        return SessionManager.shared.db.collection(SessionManager.collection).document(self.course)
    }
    
    var teacherRef: DocumentReference {
        return SessionManager.shared.db.collection(SessionManager.collection).document(self.teacher)
    }
    
    let collection = SessionManager.collection
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
        guard let courseUid = map["course"] as? String else {
            throw QError.insufficientData
        }
           
        guard let teacherUid = map["teacher"] as? String else {
            throw QError.insufficientData
        }
           
        guard let expired = map["expired"] as? Bool else {
            throw QError.insufficientData
        }
        
        guard let timestamp = map["timestamp"] as? Timestamp else {
            throw QError.insufficientData
        }
           
        self.course = courseUid
        self.teacher = teacherUid
        self.expired = expired
        self.timestamp = timestamp.dateValue()
    }
    
    // Convert back to map for saving in Firebase
    var mapped: [String: Any] {
        return [
            "course": self.course,
            "teacher": self.teacher,
            "expired": self.expired,
            "timestamp": Timestamp(date: self.timestamp)
        ]
    }
    
}
