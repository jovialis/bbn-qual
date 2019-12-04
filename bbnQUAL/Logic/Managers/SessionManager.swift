//
//  SessionManager.swift
//  bbnQUAL
//
//  Created by Dylan Hanson on 12/3/19.
//  Copyright © 2019 Jovialis. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
import Signals

class SessionManager {
    
    fileprivate(set) static var shared = SessionManager()
    fileprivate(set) lazy var db = Firestore.firestore()
    static let collection = "sessions"
    
    fileprivate init() {
        
    }
    
    func getCurrentUserSession() -> CallbackSignal<QualSession?> {
        let callback = CallbackSignal<QualSession?>()
        
        // Obtain user object
        UserManager.shared.getUser().then(listener: self) {
            switch $0 {
            case .success(let user):
                
                // Obtain session for the user
                self.getSession(user: user).then(listener: self) {
                    switch $0 {
                    case .success(let session):
                        callback.fire(.success(object: session))
                    case .failure(let error):
                        callback.fire(.failure(error: error))
                    }
                }
                
            case .failure(let error):
                callback.fire(.failure(error: error))
            }
        }
        
        return callback
    }
    
    func getSession(uid: String) -> CallbackSignal<QualSession> {
        let callback = CallbackSignal<QualSession>()
        
        // Create session
        let session = QualSession(uid: uid)
        
        // Attempt session load
        session.handler.load().then(listener: self) {
            switch $0 {
            case .success:
                callback.fire(.success(object: session))
            case .failure(let error):
                callback.fire(.failure(error: error))
            }
        }
        
        return callback

    }
    
    func getSession(user: QualUser) -> CallbackSignal<QualSession?> {
        let callback = CallbackSignal<QualSession?>()
                
        // Only look for a session if the user is in a class
        if user.inCourse {
            // Find class session for the user's class that's not expired
            let collection = self.db.collection(SessionManager.collection)
            collection.document(user.course).getDocument { document, error in
                // Validate that we got documents
                guard let document = document else {
                    callback.fire(.failure(error: error!))
                    return
                }
                
                guard let data = document.data() else {
                    callback.fire(.success(object: nil))
                    return
                }
                
                // Grab the first and only document
                let session = QualSession(uid: document.documentID, map: data)
                if let session = session {
                    if !session.expired {
                        callback.fire(.success(object: session))
                        return
                    }
                }
                
                callback.fire(.success(object: nil))
            }
        } else {
            callback.fire(.success(object: nil))
        }

        return callback
    }
    
}

extension SessionManager {
    
    enum SMError {
        
        case noSessionsForUser
        
        var localizedDescription: String {
            switch self {
            case .noSessionsForUser:
                return "There are no relevant sessions for the user."
            }
        }
        
    }
    
}
