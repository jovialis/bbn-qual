//
//  TeacherCourseSessionStatusController.swift
//  bbnQUAL
//
//  Created by Dylan Hanson on 1/5/20.
//  Copyright © 2020 Jovialis. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import Firebase
import SwiftyJSON
import Bond
import Signals

class TeacherCourseSessionStatusController: UIViewController {
	
	var course: Course!
	private var session = Signal<CourseSession?>()

	private var loading: UIActivityIndicatorView!
	private var masterStack: UIStackView!
	private var leftStack: UIStackView!
	private var rightStack: UIStackView!
	private var countdownTimer: Timer?
	
	private var sessionCollectionObserver: ListenerRegistration!
	private var sessionExpirationObserver: ActionWatchSessionExpiration?
	
	convenience init(course: Course) {
		self.init()
		self.course = course
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Background
		self.view.backgroundColor = .secondarySystemBackground
		
		// Setup
		self.setupLoading()
		self.setupMasterStack()
		
		// Constrain own view height
		self.view.snp.makeConstraints { (constrain: ConstraintMaker) in
			constrain.height.equalTo(100)
		}
		
		// Handle changes in the session
		self.observeSessionAndUpdateViews()
		
		// Observe changes in the sessions document
		self.observeChangesInSessionsCollection()
	}
	
	private func setupLoading() {
		self.loading = UIActivityIndicatorView()
		self.view.addSubview(self.loading)
		
		self.loading.hidesWhenStopped = true
		self.loading.startAnimating()
		
		// Constrain
		self.loading.snp.makeConstraints { (constrain: ConstraintMaker) in
			constrain.center.equalToSuperview()
		}
	}
	
	private func setupMasterStack() {
		// Stack
		self.masterStack = UIStackView()
		self.view.addSubview(self.masterStack)
		
		// Configure stack
		self.masterStack.axis = .horizontal
		self.masterStack.distribution = .equalSpacing
		self.masterStack.alignment = .fill
		
		// Constrain
		self.masterStack.snp.makeConstraints { (constrain: ConstraintMaker) in
			constrain.leading.trailing.top.bottom.equalToSuperview().inset(25)
		}
		
		// Left stack
		self.leftStack = UIStackView()
		self.masterStack.addArrangedSubview(leftStack)
		
		// Configure left stack
		self.leftStack.axis = .horizontal
		self.leftStack.alignment = .center
		self.leftStack.spacing = 20
				
		// Right stack
		self.rightStack = UIStackView()
		self.masterStack.addArrangedSubview(rightStack)
		
		// Configure right stack
		self.rightStack.axis = .horizontal
		self.rightStack.alignment = .center
		self.rightStack.spacing = 40
		
		self.leftStack.snp.makeConstraints { $0.height.equalToSuperview() }
		self.rightStack.snp.makeConstraints { $0.height.equalToSuperview() }
	}
	
	private func observeSessionAndUpdateViews() {
		// Listen to changes in session
		self.session.subscribe(with: self) { session in
			// Update view
			self.redisplay(session: session)
			
			// Cancel previous listener
			if let previousSessionObserver = self.sessionExpirationObserver {
				previousSessionObserver.cancel()
				self.sessionExpirationObserver = nil
			}
			
			// Listen for session expiration
			if let session = session {
				// Create and store expiration action
				self.sessionExpirationObserver = ActionWatchSessionExpiration(document: session.ref)
				
				// Watch for expiration
				self.sessionExpirationObserver!.execute().then(listener: self) {
					
					// Remove listener
					self.sessionExpirationObserver = nil
					
					// Update session as none
					self.session.fire(nil)
					
				}
			}
		}
	}
	
	// Observe changes in sessions collection. If we find one, attempt to re-fetch a session
	private func observeChangesInSessionsCollection() {
		// Reference
		let collectionRef = self.course.ref.collection("sessions")
		self.sessionCollectionObserver = collectionRef.addSnapshotListener { (snapshot: QuerySnapshot?, error: Error?) in
			if let _ = snapshot {
				
				// On a change, we just reload the local session
				self.getCurrentSessionRefAndUpdateObservers()
				
			} else {
				
				print(error!)
				
			}
		}
	}
	
	private func getCurrentSessionRefAndUpdateObservers() {
		// Obtain session via action
		ActionGetClassSession(course: self.course.ref).execute().then(listener: self) {
			switch $0 {
			case .success(let sessionRef):
				
				// No session ref means no session
				guard let sessionRef = sessionRef else {
					self.session.fire(nil)
					return
				}
				
				// Obtain session object
				ActionGetSessionContent(sessionRef: sessionRef).execute().then(listener: self) {
					switch $0 {
					case .success(let session):
						// Update session
						self.session.fire(session)
						
					case .failure(let error):
						print(error)
					}
				}
				
			case .failure(let error):
				print(error)
				break
			}
		}
	}
	
	private func redisplay(session: CourseSession?) {
		// Stop loading indicator
		if self.loading.isAnimating {
			self.loading.stopAnimating()
		}
		
		
		// Stop timer
		if let timer = self.countdownTimer {
			timer.invalidate()
		}
		
		// Dispose of all previously displayed views
		self.leftStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
		self.rightStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
		
		// Status light
		let statusLight = UIView()
		self.leftStack.addArrangedSubview(statusLight)
		statusLight.layer.cornerRadius = 7
		statusLight.snp.makeConstraints { (constrain: ConstraintMaker) in
			constrain.height.width.equalTo(14)
		}
		
		// In class label
		let classLabel = UILabel()
		self.leftStack.addArrangedSubview(classLabel)
		classLabel.font = UIFont(name: "PTSans-Regular", size: 24)
		classLabel.textColor = .secondaryLabel
		
		// Display session options if session isn't null, startSession option otherwise
		if let session = session {
			
//			LEFT
			
			
			// Pink status
			statusLight.backgroundColor = UIColor(named: "Pink")
			
			UIView.animate(withDuration: 1, delay: 0, options: [ .repeat, .autoreverse ], animations: {
				statusLight.layer.opacity = 0.4
			}, completion: nil)
			
			// Label
			classLabel.text = "In Class"
			
			// Minutes label
			let minutesLabel = UILabel()
			self.leftStack.addArrangedSubview(minutesLabel)
			minutesLabel.font = UIFont(name: "PTSans-Regular", size: 24)
			minutesLabel.textColor = .label
			
			// Update minutes label every second
			self.countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
				let expirationTime = session.expiration
				
				let secondsLeft = expirationTime.timeIntervalSince(Date())
				let minutesLeft = floor(secondsLeft / 60) + 1
				
				var text = ""
				if minutesLeft <= 1 {
					text = "\( Int(secondsLeft) ) Second\( secondsLeft == 1 ? "" : "s" ) Left"
				} else {
					text = "\( Int(minutesLeft) ) Minute\( minutesLeft == 1 ? "" : "s" ) Left"
				}
				
				minutesLabel.text = text
			}
			
			self.countdownTimer!.fire()
			
			
//			RIGHT
			
			
			// Extend Buttons Stack
			let extendButtonsStack = UIStackView()
			self.rightStack.addArrangedSubview(extendButtonsStack)
			extendButtonsStack.spacing = 20
			extendButtonsStack.axis = .horizontal
			extendButtonsStack.distribution = .fill
			extendButtonsStack.alignment = .center
			extendButtonsStack.snp.makeConstraints { $0.height.equalToSuperview() }
			
			// End session Buttons Stack
			let dismissButtonsStack = UIStackView()
			self.rightStack.addArrangedSubview(dismissButtonsStack)
			dismissButtonsStack.spacing = 20
			dismissButtonsStack.axis = .horizontal
			dismissButtonsStack.distribution = .fill
			dismissButtonsStack.alignment = .center
			dismissButtonsStack.snp.makeConstraints { $0.height.equalToSuperview() }

			// Extend sessions label
			let extendLabel = UILabel()
			extendButtonsStack.addArrangedSubview(extendLabel)
			extendLabel.font = UIFont(name: "PTSans-Regular", size: 22)
			extendLabel.textColor = UIColor(named: "Pink")
			extendLabel.text = "Extend Session"

			// End sessions label
			let dismissLabel = UILabel()
			dismissButtonsStack.addArrangedSubview(dismissLabel)
			dismissLabel.font = UIFont(name: "PTSans-Regular", size: 22)
			dismissLabel.textColor = .secondaryLabel
			dismissLabel.text = "End Session"

			// Extend session button
			let extendSessionButton = ActionButton(
				title: "+5 Min",
				background: UIColor(named: "Pink")!,
				text: self.view.backgroundColor!
			)
			
			extendButtonsStack.addArrangedSubview(extendSessionButton)
			extendSessionButton.snp.makeConstraints { $0.height.equalToSuperview() }

			extendSessionButton.onTouchUpInside.subscribe(with: self) {
				
				if !extendSessionButton.loading {
					// Start animating
					extendSessionButton.showLoading()

					ActionExtendSession(session: session, seconds: 5 * 60).execute().then(listener: self) {
						switch $0 {
						case .success:
							break
							
						case .failure(let error):
							print(error)
						}
						
						// Stop animating
						extendSessionButton.hideLoading()
					}
				}
				
			}
			
			// Extend session now button
			let endNowButton = ActionButton(
				title: "Now",
				background: self.view.backgroundColor!,
				text: .secondaryLabel,
				border: true
			)
			
			dismissButtonsStack.addArrangedSubview(endNowButton)
			endNowButton.snp.makeConstraints { $0.height.equalToSuperview() }
			
			endNowButton.onTouchUpInside.subscribe(with: self) {
				
				if !endNowButton.loading {
					// Start animating
					endNowButton.showLoading()

					ActionEndSession(sessionRef: session.ref).execute().then(listener: self) {
						switch $0 {
						case .success:
							break
							
						case .failure(let error):
							print(error)
						}
						
						// Stop animating
						endNowButton.hideLoading()
					}
				}
				
			}
			
			// Extend session soon button
			let endSoonButton = ActionButton(title: "In 30 Sec", background: .secondaryLabel, text: self.view.backgroundColor!)
			
			dismissButtonsStack.addArrangedSubview(endSoonButton)
			endSoonButton.snp.makeConstraints { $0.height.equalToSuperview() }
			
			endSoonButton.onTouchUpInside.subscribe(with: self) {
				
				if !endSoonButton.loading {
					// Start animating
					endSoonButton.showLoading()

					ActionEndSession(sessionRef: session.ref, remainingSeconds: 30).execute().then(listener: self) {
						switch $0 {
						case .success:
							break
							
						case .failure(let error):
							print(error)
						}
						
						// Stop animating
						endSoonButton.hideLoading()
					}
				}
				
			}
			
		} else {
			
			// Gray status
			statusLight.backgroundColor = UIColor.tertiarySystemGroupedBackground
			
			// Label
			classLabel.text = "Not In Class"
			
			// Start session button
			let startSessionButton = ActionButton(
				title: "Start Session",
				background: UIColor(named: "Pink")!,
				text: self.view.backgroundColor!
			)
						
			self.rightStack.addArrangedSubview(startSessionButton)
			startSessionButton.snp.makeConstraints { $0.height.equalToSuperview() }


			// Start session when tapped
				
			startSessionButton.onTouchUpInside.subscribe(with: self) {
				
				if !startSessionButton.loading {
					// Start animating
					startSessionButton.showLoading()
					
					ActionStartSession(courseRef: self.course.ref).execute().then(listener: self) {
						switch $0 {
						case .success(let session):
							self.session.fire(session)
							
						case .failure(let error):
							print(error)
						}
						
						// Stop animating
						startSessionButton.hideLoading()
					}
				}
				
			}
			
		}
	}
	
}
