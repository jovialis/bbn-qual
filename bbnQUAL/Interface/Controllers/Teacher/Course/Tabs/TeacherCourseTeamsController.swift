//
//  TeacherCourseMembersController.swift
//  bbnQUAL
//
//  Created by Dylan Hanson on 1/3/20.
//  Copyright © 2020 Jovialis. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import SnapKit
import SwiftyJSON
import Bond

class TeacherCourseTeamsController: UIViewController {
	
	var course: Course!

	private var loading: UIActivityIndicatorView!
	
	private var listener: ListenerRegistration?

	convenience init(course: Course) {
		self.init()
		self.course = course
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Setup loading indicator
		self.setupLoading()
		self.loading.startAnimating()
		
		// Observe courses
	}
	
	deinit {
		if let listener = self.listener {
			listener.remove()
		}
	}
	
	private func setupLoading() {
		self.loading = UIActivityIndicatorView()
		self.loading.style = .large
		self.loading.hidesWhenStopped = true
		
		self.view.addSubview(self.loading)
		
		self.loading.snp.makeConstraints { (constrain: ConstraintMaker) in
			constrain.centerX.equalToSuperview()
		} // /4
	}
	
	private func observeCourseGroups() {
		// Cancel current listener
		if let listener = self.listener {
			listener.remove()
			self.listener = nil
		}
		
		// Reference collection
		let groupsRef = course.ref.collection("teams")
		self.listener = groupsRef.addSnapshotListener { (snapshot: QuerySnapshot?, error: Error?) in
			if let snapshot = snapshot {
				let documents = snapshot.documents
				
				// Attempt to parse documents data
				let teams: [Team] = documents.compactMap { snapshot in
					// Extract data
					let data = snapshot.data()
					
					// Parse JSON
					let json = JSON(data)
					return Team(reference: snapshot.reference, json: json)
				}
				
				// Update observable
				self.updateTeamsDisplay(teams: teams)
				
			} else {
				
				self.present(ErrorRetryController(
					title: "Teams Error",
					message: "Something went wrong when fetching teams.",
					alertTitle: "Retry")
				{
					// Set observer again on error
					self.observeCourseGroups()
					
				}, animated: true, completion: nil)
				
			}
		}
	}
	
	private func updateTeamsDisplay(teams: [Team]) {
		
		print(teams)
		
	}
	
}
