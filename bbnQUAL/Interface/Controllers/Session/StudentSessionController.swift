//
//  StudentSessionController.swift
//  bbnQUAL
//
//  Created by Dylan Hanson on 1/1/20.
//  Copyright © 2020 Jovialis. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import Firebase

class StudentSessionController: UIViewController {
	
	// This VC searches for a Session for the user. If the session is lost, it pushes back to self
	
	var isTopController: Bool { return self.navigationController?.topViewController == self }

	// Views
	private var loadingIndicator: UIActivityIndicatorView!
	private var fetchingStack: UIStackView!
	private var logoutButton: LogoutButton!
	
	private var fetching = false
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Setup view
		self.setupView()
		
		// Discover session the first time this view comes up.
		// Subsequent times it comes up we trust the user to
		// manually trigger the search
		self.discoverSession()
	}
	
	private func setupView() {
		self.view.backgroundColor = .systemBackground
		
		// Create loading indicator
		self.loadingIndicator = UIActivityIndicatorView(style: .large)
		self.view.addSubview(self.loadingIndicator)
		
		// Constrain to center
		self.loadingIndicator.snp.makeConstraints { (constrain: ConstraintMaker) in
			constrain.center.equalToSuperview()
		}
		
		// Create stack
		self.fetchingStack = UIStackView()
		self.view.addSubview(self.fetchingStack)
		
		// Configure stack
		self.fetchingStack.alignment = .center
		self.fetchingStack.spacing = 50
		self.fetchingStack.axis = .vertical
		
		// Constrain stack
		self.fetchingStack.snp.makeConstraints { (constrain) in
			constrain.center.equalToSuperview()
		}
		
		// Label
		let sessionsLabel = UILabel()
		self.fetchingStack.addArrangedSubview(sessionsLabel)
		
		// Configure label
		sessionsLabel.text = "No Class Session"
		sessionsLabel.font = UIFont(name: "PTSans-Bold", size: 60)
		
		// Button
		let fetchSessionButton = UIButton()
		self.fetchingStack.addArrangedSubview(fetchSessionButton)
		
		// Configure button
		fetchSessionButton.setTitle("Retry", for: .normal)
		fetchSessionButton.backgroundColor = .label
		fetchSessionButton.setTitleColor(.systemBackground, for: .normal)
		fetchSessionButton.titleEdgeInsets = UIEdgeInsets(top: -10, left: -35, bottom: -10, right: -35)
		
		// On click
		_ = fetchSessionButton.reactive.tapGesture().observe { _ in
			self.discoverSession()
		}

		// Add profile button
		self.logoutButton = LogoutButton()
		self.view.addSubview(self.logoutButton)
		
		self.logoutButton.snp.makeConstraints { (constrain: ConstraintMaker) in
			constrain.centerX.equalToSuperview()
			constrain.bottom.equalToSuperview().inset(30)
		}
		
		// Showloading by default
		self.showLoading()
	}
	
	private func showLoading() {
		self.loadingIndicator.isHidden = false
		self.loadingIndicator.startAnimating()
		
		self.fetchingStack.isHidden = true
		
		self.logoutButton.isHidden = true
	}
	
	private func showRetry() {
		self.loadingIndicator.isHidden = true
		self.fetchingStack.isHidden = false
		
		self.logoutButton.isHidden = false
	}
	
	private func discoverSession() {
		// One request at a time
		if self.fetching {
			return
		}
		
		self.fetching = true
		
		// Discover session action
		ActionGetStudentSession().execute().then(listener: self) { (res) in
			
			// Handle result
			if let res = res {
				// Successfully grabbed a session. Create an expiration observer action
				// and tell it to call sessionExpired once the session expires and is
				// unrecoverable.
				ActionWatchSessionExpiration(document: res.session).execute().then(listener: self) {
					// Session expired
					self.sessionExpired()
				}
				
				// Push to student
				self.pushToStudent(course: res.course, team: res.team)
				
			} else {
				// No session found. Force user to manually discover one
				self.showRetry()
			}
			
			// No longer fetching
			self.fetching = false
			
		}
	}
	
	private func sessionExpired() {
		// Return Navigation to self
		self.popToSelf()
		
		// Show retry
		self.showRetry()
	}
	
	// Clear the navigation stack back to self.
	private func popToSelf() {
		if !self.isTopController {
			self.navigationController?.popToViewController(self, animated: false)
		}
	}
	
	// Push to student VC
	private func pushToStudent(course: CourseOverview, team: TeamOverview) {
		// Instantiate controller
		let controller = StudentViewController(course: course, team: team)
		self.navigationController?.pushViewController(controller, animated: false)
	}
	
}
