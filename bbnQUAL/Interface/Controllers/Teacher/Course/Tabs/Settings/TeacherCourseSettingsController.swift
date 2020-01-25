//
//  TeacherCourseSettingsController.swift
//  bbnQUAL
//
//  Created by Dylan Hanson on 1/24/20.
//  Copyright © 2020 Jovialis. All rights reserved.
//

import Foundation
import UIKit

class TeacherCourseSettingsController: UIViewController {
	
	private var course: Course!
	
	private(set) var settingsStoryboardController: TeacherCourseSettingsStoryboardController!
	
	convenience init(course: Course) {
		self.init()
		self.course = course
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Embed the controller into this view
		self.embedController()
	}
	
	private func embedController() {
		// Create storyboard
		let storyboard = UIStoryboard(name: "TeacherCourseSettings", bundle: nil)
		let controller = storyboard.instantiateInitialViewController() as! TeacherCourseSettingsStoryboardController
		self.settingsStoryboardController = controller
		
		// Assign course to controller
		controller.course = self.course
		
		self.addChild(controller)

		// Add controller's view to self
		self.view.addSubview(controller.view)
		
		// Configure Child View
		controller.view.frame = self.view.bounds
		controller.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

		// Add child vc
		controller.didMove(toParent: self)
	}
	
}
