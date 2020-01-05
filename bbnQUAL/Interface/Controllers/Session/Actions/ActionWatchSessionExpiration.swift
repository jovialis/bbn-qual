//
//  ActionWatchSessionExpiration.swift
//  bbnQUAL
//
//  Created by Dylan Hanson on 1/1/20.
//  Copyright © 2020 Jovialis. All rights reserved.
//

import Foundation
import Signals
import Firebase

class ActionWatchSessionExpiration: Action<Void> {
	
	private var executed: Bool = false

	private var sessionRef: DocumentReference
	private var listener: ListenerRegistration?
	
	private let MAX_RECONNECT_ATTEMPTS = 2
	private var reconnectAttempts = 0
	
	private var sessionExpiredCallback = Signal<Void>()
	private var docStatusCallback = CallbackSignal<Bool>()
	
	private var sessionExpirationTimer: Timer?
	
	init(document: DocumentReference) {
		self.sessionRef = document
	}
	
	func cancel() {
		if let listener = self.listener {
			listener.remove()
		}
	}
	
	override func execute() -> Signal<Void> {
		// Only allow single execution
		if self.executed {
			return self.sessionExpiredCallback
		}
		
		self.executed = true
		
		// Observe session doc status callback. We have
		// one singleton callback to ensure we're always lsitening
		self.docStatusCallback.then(listener: self) {
			switch $0 {
			case .success(let expired):
				if expired {
					// If the session has expired, attempt to find a new one.
					self.attemptToDiscoverNewSession().then(listener: self) { (sessionRef: DocumentReference?) in
						// Success means doc
						if let sessionRef = sessionRef {
							// Update our sessionRef
							self.sessionRef = sessionRef
							
							// Attempt to listen to the new document
							self.observeSession()
						} else {
							// Pass final session expiration
							self.sessionExpiredCallback.fire(())
						}
					}
				}
				
				break
				
			case .failure(let error):
				print(error)
				
				// Attempt to reestablish the listener
				if !self.attemptToReconnectSessionObserver() {
					// If we reconnected too many times, tell the VC that we lost the session
					self.sessionExpiredCallback.fire(())
				}
				
				break
			}
		}
		
		// When we're ultimately returning the session expiration, cancel timer and document listener
		self.sessionExpiredCallback.then(listener: self) {
			// Cancel timer
			if let timer = self.sessionExpirationTimer {
				timer.invalidate()
				self.sessionExpirationTimer = nil
			}
			
			// Cancel observation
			if let listener = self.listener {
				listener.remove()
				self.listener = nil
			}
		}
		
		// Observe sessionDoc, passing changes to docStatusCallback
		self.observeSession()
		
		return self.sessionExpiredCallback
	}
	
	private func observeSession() {
		// Observe changes to the session
		let listener = self.sessionRef.addSnapshotListener { (snapshot: DocumentSnapshot?, error: Error?) in
			// Cancel timer whenever we update the document
			if let timer = self.sessionExpirationTimer {
				timer.invalidate()
				self.sessionExpirationTimer = nil
			}
			
			if let snapshot = snapshot {
				// Extract data
				let data = snapshot.data()!
				
				// Parse session
				if let session = SessionState(data) {
					// If we successfully connected and parsed data, reset connect attempts
					self.reconnectAttempts = 0
					
					let expired = session.expiredIncludingTime
					
					// Notify of expired status
					self.docStatusCallback.fire(.success(object: expired))
					
					// If it hasn't expired, set the Timer to listen for when
					// it does expire by time.
					if !expired {
						self.sessionExpirationTimer = session.getExpirationTimer {
							// When it does expire, call docStatusCallback saying it expired
							self.docStatusCallback.fire(.success(object: true))
						}
					}
				} else {
					self.docStatusCallback.fire(.failure(error: "Could not extract necessary data"))
				}
			} else {
				self.docStatusCallback.fire(.failure(error: error!))
			}
		}
		
		// Store listener
		self.listener = listener
	}
	
	// Returns a bool representing whether max attempts reached
	private func attemptToReconnectSessionObserver() -> Bool {
		// Increment reconnect attempts
		self.reconnectAttempts += 1
		
		// Check to make sure we aren't going over the allotted # of reconnects
		if self.reconnectAttempts > self.MAX_RECONNECT_ATTEMPTS {
			return false
		}
				
		// Cancel previous listener
		if let listener = self.listener {
			listener.remove()
		}
		
		// Start a new listening session
		self.observeSession()
		
		return true
	}
	
	private func attemptToDiscoverNewSession() -> Signal<DocumentReference?> {
		let callback = Signal<DocumentReference?>()
		
		// Cancel listener to current session
		if let listener = self.listener {
			listener.remove()
		}
		
		// Call GetSession action. I'm disabling this because if the session expires,
		// there likely isn't another. Moreover, we don't want to drive Function usage through
		// the roof.
//		ActionGetStudentSession(controller: self.controller).execute().then(listener: self) { (res) in
//			// Session ref means success
//			if let res = res {
//				// Callback with res
//				callback.fire(res.session)
//			} else {
//				callback.fire(nil)
//			}
//		}
		
		callback.fire(nil)
		
		return callback
	}
	
}

extension ActionWatchSessionExpiration {
	
	fileprivate struct SessionState {
		
		let expiration: Date
		let timestamp: Date
		let expired: Bool
		
		init?(_ data: [String: Any]) {			
			guard let expiration = data["expiration"] as? Timestamp else {
				return nil
			}
			
			guard let timestamp = data["timestamp"] as? Timestamp else {
				return nil
			}
			
			guard let expired = data["expired"] as? Bool else {
				return nil
			}
						
			self.expiration = expiration.dateValue()
			self.timestamp = timestamp.dateValue()
			self.expired = expired
		}
		
		var expiredIncludingTime: Bool {
			if self.expired {
				return true
			}
			
			// Check if expired
			return self.expiration < Date()
		}
		
		func getExpirationTimer(onExpire: @escaping () -> Void) -> Timer {
			// Create new timer to go off when the session expires
			let timer = Timer(fire: self.expiration, interval: 0, repeats: false) { (_) in
				// Trigger closure
				onExpire()
			}
			
			// Add timer to runloop
			RunLoop.main.add(timer, forMode: .common)
						
			return timer
		}
		
	}
	
}
