//
//  CreateCourseController.swift
//  bbnQUAL
//
//  Created by Dylan Hanson on 1/18/20.
//  Copyright © 2020 Jovialis. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import SnapKit
import ReactiveKit

class CreateCourseController: UIViewController {
	
	private var courseName: String = "" {
		didSet {
			self.checkCourseNameValidity()
		}
	}
	
	private var nameValid: Bool = false
	
	private var createButton: ActionButton!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Setup views
		self.setupViews()
	}
	
	private func setupViews() {
		// Master stack
		let stack = UIStackView()
		stack.axis = .vertical
		stack.alignment = .center
		
		// Text field
		let field = UITextField()
		field.placeholder = "Course Name"
		
		field.onValueChanged.subscribe(with: self) {
			self.courseName = field.text ?? ""
		}
		
		stack.addArrangedSubview(field)
		
		// Create button
		self.createButton = ActionButton()
		self.createButton.onTouchUpInside.subscribe(with: self) {
			self.create()
		}
		
		self.view.addSubview(stack)
		
		// Constrain stack
		stack.snp.makeConstraints { $0.center.equalToSuperview() }
	}
	
	private func checkCourseNameValidity() {
		// Mark invalid
		self.nameValid = false

		// Show loading
		self.createButton.showLoading()
		
		// Update button
		self.updateButton()
		
		// Check if a course with that name exists
		ActionCourseNameExists(name: self.courseName).execute().then(listener: self) {
			switch $0 {
			case .success(let exists):
				// Success. Update name valid
				self.nameValid = !exists
				
				// Update button
				self.createButton.hideLoading()
				self.updateButton()
				
			case .failure(let error):
				print(error)
				
				self.present(ErrorRetryController(title: "Something Went Wrong", message: "Could not check name validity", alertTitle: "Retry", onRetry: {
					
					// Create again
					self.checkCourseNameValidity()
					
				}), animated: false, completion: nil)
				
			}
		}
	}
	
	private func updateButton() {
		// If it's loading
		var disabled: Bool
		
		if self.createButton.loading {
			disabled = true
		} else if !self.nameValid {
			disabled = true
			
			self.createButton.setTitle("Invalid Name", for: .normal)
		} else {
			disabled = false
			
			self.createButton.setTitle("Create Course", for: .normal)
		}
		
		if disabled {
			self.createButton.backgroundColor = .tertiaryLabel
			self.createButton.setTitleColor(.tertiarySystemBackground, for: .normal)
		} else {
			self.createButton.backgroundColor = .label
			self.createButton.setTitleColor(.systemBackground, for: .normal)
		}
	}
	
	private func create() {
		// No course name given
		if self.courseName.trimmingCharacters(in: .whitespaces).isEmpty {
			return
		}
		
		// Button is loading
		if self.createButton.loading || !self.nameValid {
			return
		}
		
		self.createButton.showLoading()
		
		let functionRef = Functions.functions().httpsCallable("createCourseUponTeacherRequest")
		functionRef.call([ "name": self.courseName ]) { (result: HTTPSCallableResult?, error: Error?) in
		
			if let _ = result {
				
				// Dismiss self
				self.dismiss(animated: true, completion: nil)
				
			} else {
				print(error!)
				
				self.present(ErrorRetryController(title: "Something Went Wrong", message: "Could not create a course.", alertTitle: "Retry", onRetry: {
					
					// Create again
					self.create()
					
				}), animated: false, completion: nil)
			}
			
			self.createButton.hideLoading()
			
		}
	}
	
}
