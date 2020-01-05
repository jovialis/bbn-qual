//
//  TeacherCourseSessionController.swift
//  bbnQUAL
//
//  Created by Dylan Hanson on 1/3/20.
//  Copyright © 2020 Jovialis. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import Firebase
import SwiftyJSON

class TeacherCourseSessionController: UIViewController {
	
	var course: Course!
	
	private var stack: UIStackView!
	private var loading: UIActivityIndicatorView!
	
	convenience init(course: Course) {
		self.init()
		self.course = course
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.setupMasterStack()
		
		self.addChildControllers()
//		// Setup loading indicator
//		self.setupLoading()
//		self.loading.startAnimating()
		
		// Load session
	}
	
	private func setupMasterStack() {
		// Master stack
		self.stack = UIStackView()
		self.view.addSubview(self.stack)
		
		// Configure stack
		self.stack.axis = .vertical
		self.stack.distribution = .fill
		self.stack.alignment = .fill
		
		// Constrain stack
		self.stack.snp.makeConstraints { (constrain: ConstraintMaker) in
			constrain.leading.trailing.top.equalToSuperview()
		}
	}
//
//	private func setupLoading() {
//		self.loading = UIActivityIndicatorView()
//		self.loading.style = .large
//		self.loading.hidesWhenStopped = true
//
//		self.view.addSubview(self.loading)
//
//		self.loading.snp.makeConstraints { (constrain: ConstraintMaker) in
//			constrain.center.equalToSuperview()
//		}
//	}
//
	private func addChildControllers() {
		// Session controller
		let sessionController = TeacherCourseSessionStatusController(course: self.course)
		self.stack.addArrangedSubview(sessionController.view)
		
		// Add child
		self.addChild(sessionController)
		sessionController.willMove(toParent: self)
	}
	
}
