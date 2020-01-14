//
//  TeacherCourseSessionProgressController.swift
//  bbnQUAL
//
//  Created by Dylan Hanson on 1/13/20.
//  Copyright © 2020 Jovialis. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class TeacherCourseSessionProgressController: UIViewController {
	
	private var course: Course!
	
	private var loading: UIActivityIndicatorView!
	private var masterStack: UIStackView!

	convenience init(course: Course) {
		self.init()
		self.course = course
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Setup
		self.setupLoading()
		self.setupMasterStack()
		
//		// Handle changes in the session
//		self.observeSessionAndUpdateViews()
//
//		// Observe changes in the sessions document
//		self.observeChangesInSessionsCollection()
		
		// Create progression view
		let progressionView = ProgressionTrackView()
		progressionView.groupName = "Group 1"
		progressionView.members = ["Dylan", "Joseph"]
		
		progressionView.numRegular = 3
		progressionView.numChallenge = 2
		
		progressionView.assignedBeginner = true
		progressionView.assignedRegular = ["3", "1", "4"]
		progressionView.assignedChallenge = ["6", "7"]
		progressionView.finished = true
		
		self.masterStack.addArrangedSubview(progressionView)
		
		
		let progressionView2 = ProgressionTrackView()
		progressionView2.groupName = "Group 2"
		progressionView2.members = ["Isabelle", "Julia"]
		
		progressionView2.numRegular = 3
		progressionView2.numChallenge = 2
		
		progressionView2.assignedBeginner = true
		progressionView2.assignedRegular = ["4", "1", "3"]
		progressionView2.assignedChallenge = ["9"]
		progressionView2.finished = false
		
		self.masterStack.addArrangedSubview(progressionView2)
		
		
		
		let labelView = ProgressionTrackLabelView()
		labelView.numRegular = 3
		labelView.numChallenge = 2
		self.masterStack.addArrangedSubview(labelView)

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
		self.masterStack.axis = .vertical
		self.masterStack.distribution = .equalSpacing
		self.masterStack.spacing = 80
		self.masterStack.alignment = .fill
		
		// Constrain
		self.masterStack.snp.makeConstraints { (constrain: ConstraintMaker) in
			constrain.leading.trailing.top.equalToSuperview().inset(25)
		}
	}
	
}
