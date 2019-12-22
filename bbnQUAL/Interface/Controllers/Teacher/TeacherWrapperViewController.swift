//
//  TeacherWrapperViewController.swift
//  bbnQUAL
//
//  Created by Dylan Hanson on 12/14/19.
//  Copyright © 2019 Jovialis. All rights reserved.
//

import Foundation
import UIKit

class TeacherWrapperViewController: UIViewController {
	
	var teacher: QualUser!
	
	@IBOutlet weak var consoleNameLabel: UILabel!
	@IBOutlet weak var teacherNameButton: UIButton!
	
	@IBOutlet weak var navigationContainerView: UIView!
	private var childNavigation: UINavigationController!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Setup view
		self.consoleNameLabel.text = (self.teacher.access == 1 ? "Teacher" : "Admin") + " Console"
		self.teacherNameButton.setTitle(self.teacher.name, for: .normal)
		
		// Setup container
		self.setupContainerView()
		self.initialView()
	}

	private func setupContainerView() {
		// Instantiate navigation controller
		let navigationController = UINavigationController()
//		navigationController.navigationBar.isHidden = true
		
		// Make navigation bar transparent
		navigationController.navigationBar.setBackgroundImage(UIImage(), for: .default) //UIImage.init(named: "transparent.png")
		navigationController.navigationBar.shadowImage = UIImage()
		navigationController.navigationBar.isTranslucent = true
		navigationController.view.backgroundColor = .clear
		
		// Add child controller
		self.addChild(navigationController)
		
		self.navigationContainerView.addSubview(navigationController.view)
		
		// Configure Child View
		navigationController.view.frame = self.navigationContainerView.bounds
		navigationController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

		// Notify Child View Controller
		navigationController.didMove(toParent: self)
		
		self.childNavigation = navigationController
	}
	
	private func initialView() {
		// Push to course list view
		let controller = TeacherCoursesViewController()
		controller.teacher = self.teacher
		
		self.childNavigation.pushViewController(controller, animated: false)
	}
	
}
