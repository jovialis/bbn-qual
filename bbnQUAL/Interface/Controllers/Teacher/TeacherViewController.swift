//
//  TeacherWrapperViewController.swift
//  bbnQUAL
//
//  Created by Dylan Hanson on 12/14/19.
//  Copyright © 2019 Jovialis. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import CollectionKit

class TeacherViewController: UIViewController {
		
	var access: Int!
	var user: User { return Auth.auth().currentUser! }

	@IBOutlet weak var consoleNameLabel: UILabel!
	@IBOutlet weak var teacherNameButton: UIButton!
	
	@IBOutlet weak var collectionMountingView: UIView!
	private var collectionView: CollectionView!
	
	// Data sources for collection
	private var activeCoursesSource: ArrayDataSource<Course>!
	private var archivedCoursesSource: ArrayDataSource<Course>!
	
	// Listener for courses
	private var listener: ListenerRegistration!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Setup view
		self.consoleNameLabel.text = (self.access == 1 ? "Teacher" : "Admin") + " Console"
		self.teacherNameButton.setTitle(self.user.displayName, for: .normal)
		
		// Open user on click teacher name button
		self.teacherNameButton.onTouchDown.subscribe(with: self) { _ in
			self.present(ProfileController(), animated: true, completion: nil)
		}
		
		// Setup container
		self.createCollectionView()
		self.setupCollectionProvider()
		
		// Listen to courses to display
		self.listenToCourseChanges()
	}
	
	deinit {
		self.listener.remove()
	}
	
	private func createCollectionView() {
		let view = CollectionView()
		self.collectionView = view
		
		self.collectionView.alwaysBounceVertical = true
		
		// Add subview
		self.collectionMountingView.addSubview(view)
		
		// Constrain to edges
		view.snp.makeConstraints { constrain in
			constrain.leading.equalToSuperview()
			constrain.trailing.equalToSuperview()
			constrain.top.equalToSuperview()
			constrain.bottom.equalToSuperview()
		}
	}

	private func setupCollectionProvider() {
		// Default data array
		let data: [Course] = []

		let activeCoursesDataSource = ArrayDataSource(data: data)
		let archivedCoursesDataSource = ArrayDataSource(data: data)

		let viewSource = ClosureViewSource { (view: CourseView, data: Course, index: Int) in
			view.course = data
			view.backgroundColor = .secondarySystemBackground

			// Layout
			view.layoutSubviews()

			// Open the course when clicked
			view.clickedButton?.onTouchUpInside.subscribe(with: self, callback: {
				self.openCourse(course: data)
			})
		}

		let sizeSource = { (index: Int, data: Course, collectionSize: CGSize) -> CGSize in
			return CGSize(width: 300, height: 100)
		}

		let activeCoursesProvider = BasicProvider(
			dataSource: activeCoursesDataSource,
			viewSource: viewSource,
			sizeSource: sizeSource
		)

		let archivedCoursesProvider = BasicProvider(
			dataSource: archivedCoursesDataSource,
			viewSource: viewSource,
			sizeSource: sizeSource
		)

		activeCoursesProvider.layout = FlowLayout(spacing: 30, justifyContent: .start, alignItems: .center)
		archivedCoursesProvider.layout = FlowLayout(spacing: 30, justifyContent: .start, alignItems: .center)

		// Active header provider
		let activeHeaderProvider = ComposedHeaderProvider(
		  headerViewSource: { (view: UILabel, data, index) in
			
			  view.textColor = .white
			view.textAlignment = .left
			  view.text = "Active Courses"
			  view.font = UIFont(name: "PTSans-Bold", size: 26)

		  },
		  headerSizeSource: { (index, data, maxSize) -> CGSize in
			return CGSize(width: maxSize.width, height: 50)
		  },
		  sections: [activeCoursesProvider]
		)

		activeHeaderProvider.layout = FlowLayout(spacing: 20)

		// Archived Header provider
		let archivedHeaderProvider = ComposedHeaderProvider(
			headerViewSource: { (view: UILabel, data, index) in
				
				view.textColor = .white
				view.textAlignment = .left
				view.text = "Archived Courses"
				view.font = UIFont(name: "PTSans-Bold", size: 26)
				
			},
			headerSizeSource: { (index, data, maxSize) -> CGSize in
				return CGSize(width: maxSize.width, height: 50)
			},
			sections: [archivedCoursesProvider]
		)

		archivedCoursesProvider.layout = FlowLayout(spacing: 20)


		// Compound provider


		let compoundProvider = ComposedProvider(sections: [activeHeaderProvider, archivedHeaderProvider])
		compoundProvider.layout = FlowLayout(spacing: 50).transposed()

		self.collectionView.provider = compoundProvider

		// Save the providers
		self.activeCoursesSource = activeCoursesDataSource
		self.archivedCoursesSource = archivedCoursesDataSource
	}

	private func listenToCourseChanges() {
		// Listen to changes
		var query: Query = Firestore.firestore().collection("courses")

		// If user isn't an admin, i.e. is just a teacher, only query for courses
		// where they are explicitely a teacher
		if self.access == 1 {
			query = query.whereField("teacherIds", arrayContains: self.user.uid)
		}

		// Listen for all courses relevant to the user
		let listener = query.addSnapshotListener { (snapshot: QuerySnapshot?, error: Error?) in
			if let snapshot = snapshot {
				let courses: [Course] = snapshot.documents.compactMap { (doc) in
					// Get document ID
					let data = doc.data()
					
					let json = JSONObject(data)
					if let course = Course(ref: doc.reference, json: json) {
						return course
					} else {
						print("Could not parse Course from JSON")
						return nil
					}
				}

				self.activeCoursesSource.data = courses.filter({ !$0.archived })
				self.archivedCoursesSource.data = courses.filter({ $0.archived })
			} else {
				print(error!)

				// Notify user of error
				self.present(ErrorRetryController(
					
					title: "Error Fetching Courses",
					message: "Something went wrong when fetching your courses.",
					alertTitle: "Dismiss",
					onRetry: {}
					
				), animated: true, completion: nil)
			}
		}
		
		self.listener = listener
	}
	
	private func openCourse(course: Course) {
		let storyboard = UIStoryboard(name: "TeacherCourse", bundle: nil)
		let controller = storyboard.instantiateInitialViewController() as! TeacherCourseController
		
		// Configure controller
		controller.access = self.access
		controller.coursePreset = course
		
		controller.modalPresentationStyle = .fullScreen
		controller.modalTransitionStyle = .coverVertical
		
		self.present(controller, animated: true, completion: nil)
	}
	
	@IBAction func createCourseSelected(_ sender: UIButton) {
		
		// Push to the create course controller
		let createController = CreateCourseController()
		self.present(createController, animated: true, completion: nil)
		
	}
	
}
