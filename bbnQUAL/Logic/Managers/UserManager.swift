//
//  UserManager.swift
//  bbnQUAL
//
//  Created by Dylan Hanson on 11/28/19.
//  Copyright © 2019 Jovialis. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class UserManager {
		
	fileprivate(set) static var shared = UserManager()
	fileprivate(set) lazy var db = Firestore.firestore()
	
    static let collection = "users"
	private(set) var currentUserId: String?
	
	fileprivate init() {
		
	}
	
	func setCurrentUserId(userId: String) {
		self.currentUserId = userId
	}
	
	func getUser(userId: String? = nil) -> CallbackSignal<QualUser> {
		let callback = CallbackSignal<QualUser>()
		
		var userId = userId
		
		if userId == nil {
			if self.currentUserId == nil {
				// No user error
				callback.fire(.failure(error: UMError.noLoadedUser))
				return callback
			}
			
			userId = self.currentUserId
		}
		
		// Create user
		let user = QualUser(uid: userId!)
		
		// Attempt user load
		user.handler.load().then(listener: self) {
			switch $0 {
			case .success:
				callback.fire(.success(object: user))
			case .failure(let error):
				callback.fire(.failure(error: error))
			}
		}
		
		return callback
	}
	
}

extension UserManager {
	
	enum UMError: Error {
		
		case noLoadedUser
		
		var localizedDescription: String {
			switch self {
			case .noLoadedUser:
				return "No user ID is loaded in the manager"
			}
		}
		
	}
	
}
