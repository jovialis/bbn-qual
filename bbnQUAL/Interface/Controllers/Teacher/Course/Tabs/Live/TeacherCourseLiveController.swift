//
//  TeacherCourseLiveController.swift
//  bbnQUAL
//
//  Created by Dylan Hanson on 1/25/20.
//  Copyright © 2020 Jovialis. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import Firebase

class TeacherCourseLiveController: UIViewController {
	
	private var course: Course!
	
	convenience init(course: Course) {
		self.init()
		self.course = course
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Setup the view
		self.setupView()
	}
	
	private func setupView() {
		// Create stack
		let stack = UIStackView()
		self.view.addSubview(stack)
		
		stack.axis = .vertical
		stack.alignment = .center
		stack.spacing = 40
		
		// Constrain
		stack.snp.makeConstraints { $0.center.equalToSuperview() }
	
		// Finish setup button
		let button = ActionButton(title: "Complete Setup", background: UIColor(named: "Pink")!, text: .systemBackground)
		stack.addArrangedSubview(button)
		
		// On click
		button.onTouchUpInside.subscribe(with: self) {
			button.showLoading()
			self.completeSetup()
		}
		
		// Our details label
		let label = UILabel()
		label.text = "Once you complete the Course setup, you will no longer be able to adjust Settings or rearrange teams. Please ensure that you have finished your setup completely before continuing."
		label.textColor = .secondaryLabel
		label.font = UIFont(name: "PTSans-BoldItalic", size: 22)
		
		stack.addArrangedSubview(label)
	}
	
	private func completeSetup() {
		// Function
		let function = Functions.functions().httpsCallable("courseGoLive")
		function.call([
		
			"courseId": self.course.ref.documentID
		
		]) { (result: HTTPSCallableResult?, error: Error?) in
			
			if let error = error {
				// Print
				print(error)
				
				// Retry
				self.present(ErrorRetryController(message: "Something went wrong going live.", onRetry: {
					
					self.completeSetup()
					
				}), animated: true, completion: nil)
			}
			
		}
	}
	
}
