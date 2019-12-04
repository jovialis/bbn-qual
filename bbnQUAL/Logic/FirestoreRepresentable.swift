//
//  FirestoreRepresentable.swift
//  bbnQUAL
//
//  Created by Dylan Hanson on 11/28/19.
//  Copyright © 2019 Jovialis. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

protocol FirestoreRepresentable {
	
	var collection: String { get }
	var uid: String { get }
	
	// Save a Handler
	var handler: FirestoreRepresentableHandler { get }

    // Default init
    init(uid: String)
    
	// Data init
	init?(uid: String, map: [String: Any])
	
	// Update using Firebase data
	func update(map: [String: Any]) throws
	
	// Convert back to map for saving in Firebase
	var mapped: [String: Any] { get }
	
}

// Handler to deal with all the interactions between the object and Firestore
class FirestoreRepresentableHandler {
	
	private let represented: FirestoreRepresentable
	
	let updated: CallbackSignal<Void> = CallbackSignal<Void>()
	
	init(represented: FirestoreRepresentable) {
		self.represented = represented
		
		// Listen to document updates
		self.listen()
	}
	
	private func listen() {
		// Grab firestore instance
		let firestore = Firestore.firestore()
		
		// Find document
		let collection = firestore.collection(self.represented.collection)
		let docRef = collection.document(self.represented.uid)

		// Listen to document updates
		docRef.addSnapshotListener { (snapshot: DocumentSnapshot?, error: Error?) in
			// Handle snapshot or pass an error
			if let snapshot = snapshot {
				// Attempt data parse. Otherwise throw an error
				if let data = snapshot.data() {
					// Attempt udpate object, catching any errors that are thrown
					do {
						try self.represented.update(map: data)
						self.updated.fire(.success(object: ()))
					} catch {
						self.updated.fire(.failure(error: error))
					}
				} else {
					self.updated.fire(.failure(error: FRHError.failedToParseDataFromSnapshot))
				}
			} else {
				self.updated.fire(.failure(error: error!))
			}
		}
	}
	
	func load() -> CallbackSignal<Void> {
		let callback = CallbackSignal<Void>()
		
		// Grab firestore instance
		let firestore = Firestore.firestore()
		
		// Find document
		let collection = firestore.collection(self.represented.collection)
		let docRef = collection.document(self.represented.uid)
		
		// Obtain data
		docRef.getDocument { document, error in
			if let document = document {
				// Return user if document exists, or create a new one otherwise
				if document.exists {
					let data = document.data()!
					
					// Generate user object with data
					do {
						try self.represented.update(map: data)
						
						// Call successful if we updated without an error.
						callback.fire(.success(object: ()))
					} catch {
						callback.fire(.failure(error: error))
					}
				} else {
					// No document, so nothing loaded. That's still successful
					callback.fire(.success(object: ()))
				}
			} else {
				// Error occurred
				callback.fire(.failure(error: error!))
			}
		}
		
		return callback
	}
	
	func save() -> CallbackSignal<Void> {
		let callback = CallbackSignal<Void>()
		
		// Grab firestore instance
		let firestore = Firestore.firestore()
		
		// Find document
		let collection = firestore.collection(self.represented.collection)
		let docRef = collection.document(self.represented.uid)
		
		// Save data
		docRef.setData(self.represented.mapped, merge: true) { error in
			if error == nil {
				callback.fire(.success(object: ()))
			} else {
				callback.fire(.failure(error: error!))
			}
		}
		
		return callback
	}
	
}

extension FirestoreRepresentableHandler {
	
	enum FRHError: Error {
		
		case failedToParseDataFromSnapshot
		
		var localizedDescription: String {
			switch self {
			case .failedToParseDataFromSnapshot:
				return "Failed to parse data from snapshot"
			}
		}
		
	}
	
}
