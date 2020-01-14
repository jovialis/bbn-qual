//
//  TeacherCourseSessionIcebergsController.swift
//  bbnQUAL
//
//  Created by Dylan Hanson on 1/13/20.
//  Copyright © 2020 Jovialis. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class TeacherCourseSessionIcebergsController: UIViewController {
	
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
	}
	
	override func updateViewConstraints() {
		super.updateViewConstraints()
		
		// Constrain own view height
		self.view.snp.makeConstraints { (constrain: ConstraintMaker) in
			constrain.width.equalToSuperview().dividedBy(4)
		}
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
		self.masterStack.spacing = 30
		self.masterStack.alignment = .fill
		
		// Constrain
		self.masterStack.snp.makeConstraints { (constrain: ConstraintMaker) in
			constrain.leading.trailing.top.bottom.equalToSuperview().inset(25)
		}
	}
	
}
