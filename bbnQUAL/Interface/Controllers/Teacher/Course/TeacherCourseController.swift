//
//  TeacherCourseController.swift
//  bbnQUAL
//
//  Created by Dylan Hanson on 1/2/20.
//  Copyright © 2020 Jovialis. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import SnapKit
import Bond
import SwiftyJSON
import ReactiveKit

class TeacherCourseController: UIViewController, UITabBarDelegate {
		
	@IBOutlet weak var classNameLabel: UILabel!
	@IBOutlet weak var pageButtonsStack: UIStackView!
	@IBOutlet weak var pageContainerView: UIView!
	private var tabController: UITabBarController!
	
	var user: User { return Auth.auth().currentUser! }
	var coursePreset: Course!
	var access: Int!
	lazy var courseObserver = Observable<Course>(self.coursePreset)
	
	private lazy var cachedLiveStatus: Bool = self.coursePreset.live
	var isTopController: Bool { return self.navigationController?.topViewController == self }
	
	private var listener: ListenerRegistration!
	private var observer: Disposable!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Setup tab
		self.setupTabController()
		
		// Register listeners for the course
		self.observeCourseLive()
		
		// Initial view update
		self.updateContent()
	}
	
	deinit {
		self.listener.remove()
		self.observer.dispose()
	}
	
	@IBAction func onDismiss(_ sender: Any) {
		self.dismiss(animated: true, completion: nil)
	}
	
	private func setupTabController() {
		// Create controller
		let tabController = UITabBarController()
		self.tabController = tabController
		
		// Add child controller
		self.addChild(tabController)
		
		self.pageContainerView.addSubview(tabController.view)
		
		// Configure Child View
		tabController.view.frame = self.pageContainerView.bounds
		tabController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

		// Notify Child View Controller
		tabController.didMove(toParent: self)
		
		// Hide tab bar
		tabController.hidesBottomBarWhenPushed = true
		tabController.tabBar.isHidden = true
	}
	
	private func updateContentOnCourseUpdate() {
		// Observe course
		self.observer = self.courseObserver.observe { (_) in
			// Update content
			self.updateContent()
		}
	}
	
	private func updateContent() {
		// Update course title
		self.classNameLabel.text = self.courseObserver.value.name
		
		var controllers: [ (String, UIViewController) ] = []
		
		// Add session tab if live
		if self.courseObserver.value.live {
			controllers.append(("Session Dashboard", TeacherCourseSessionController(course: self.courseObserver.value)))
		}
		
		// TODO: Append other controllers
		controllers.append(("Teams", TeacherCourseTeamsController(course: self.courseObserver.value)))
		
		// Set tabs
		self.tabController.setViewControllers(controllers.map { $0.1 }, animated: false)
		self.tabController.selectedIndex = 0
		
		// Update the buttons based on the tabs
		self.updateButtons(controllers: controllers)
	}
		
	private func updateButtons(controllers: [(String, UIViewController)]) {
		// Reset buttons
		self.pageButtonsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
		
		let buttonNames = controllers.map { $0.0 }
		let selectedIndex = self.tabController.selectedIndex
		
		for i in 0..<buttonNames.count {
			let isSelected = i == selectedIndex
			
			// Create button for index
			let button = UIButton()
			self.pageButtonsStack.addArrangedSubview(button)
			
			button.setTitle(buttonNames[i], for: .normal)
			button.setTitleColor(isSelected ? UIColor.secondaryLabel : .tertiaryLabel, for: .normal)
			button.titleLabel?.font = UIFont(name: "PTSans-Regular", size: 22)
						
			// On button click, change selected tab
			if !isSelected {
				_ = button.reactive.tap.observeNext { (_) in
					self.tabController.selectedIndex = i
					
					// Refresh views
					self.updateButtons(controllers: controllers)
				}
			}
		}
	}
	
	private func observeCourseLive() {
		// Ref
		let ref = self.coursePreset.ref
		self.listener = ref.addSnapshotListener({ (snapshot: DocumentSnapshot?, error: Error?) in
			if let snapshot = snapshot {
				// Parse JSON from snapshot
				let json = JSON(snapshot.data())
				
				guard let course = Course(ref: ref, json: json) else {
					print("Could not observe live status for course.")
					return
				}
				
				// Update course
				self.courseObserver.value = course
			} else {
				// Error
				print(error!)
			}
		})
	}
	
}
