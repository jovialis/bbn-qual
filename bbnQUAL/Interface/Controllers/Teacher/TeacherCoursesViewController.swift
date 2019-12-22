//
//  TeacherCoursesViewController.swift
//  bbnQUAL
//
//  Created by Dylan Hanson on 12/15/19.
//  Copyright © 2019 Jovialis. All rights reserved.
//

import Foundation
import UIKit
import CollectionKit
import Firebase
import FirebaseFirestoreSwift
import SnapKit

class TeacherCoursesViewController: UIViewController {
	
	var teacher: QualUser!
	
	private var collection: CollectionView!
	
	private var activeCoursesSource: ArrayDataSource<Course>!
	private var archivedCoursesSource: ArrayDataSource<Course>!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Setup collection view
		self.setupCollectionView()
		
		// Setup the different sections
		self.setupProviders()
		
		// React to course changes
		self.listenToCourseChanges()
	}
	
	private func setupCollectionView() {
		let view = CollectionView()
		self.collection = view
		
		// Add subview
		self.view.addSubview(view)
		
		// Constrain to edges
		view.snp.makeConstraints { constrain in
			constrain.leading.equalToSuperview()
			constrain.trailing.equalToSuperview()
			constrain.top.equalToSuperview()
			constrain.bottom.equalToSuperview()
		}
	}
	
	private func setupProviders() {
		// Default data array
		let data: [Course] = []
		
		let activeCoursesDataSource = ArrayDataSource(data: data)
		let archivedCoursesDataSource = ArrayDataSource(data: data)
		
		let viewSource = ClosureViewSource { (view: CourseView, data: Course, index: Int) in
			view.course = data
			view.backgroundColor = .secondarySystemBackground
			view.layer.cornerRadius = 5.0
			
			view.clickedButton?.onTouchDown.then(listener: self) {
				self.openCourse(course: data)
			}
		}
		
		let sizeSource = { (index: Int, data: Course, collectionSize: CGSize) -> CGSize in
		  return CGSize(width: 200, height: 200)
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
		
		activeCoursesProvider.layout = FlowLayout(spacing: 30, justifyContent: .start)
		archivedCoursesProvider.layout = FlowLayout(spacing: 30, justifyContent: .start)

		// Active header provider
		let activeHeaderProvider = ComposedHeaderProvider(
		  headerViewSource: { (view: UILabel, data, index) in
			  view.textColor = .white
			  view.textAlignment = .center
			  view.text = "Active Courses"
		      view.font = UIFont(name: "PT Sans", size: 26.0)
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
				view.textAlignment = .center
				view.text = "Archived Courses"
				view.font = UIFont(name: "PT Sans", size: 22.0)
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
		
		self.collection.provider = compoundProvider
		
		// Save the providers
		self.activeCoursesSource = activeCoursesDataSource
		self.archivedCoursesSource = archivedCoursesDataSource
	}
	
	private func listenToCourseChanges() {
		// Listen to changes
		var query: Query = Firestore.firestore().collection("courses")
		
		if self.teacher.access == 1 {
			query = query.whereField("teachers", arrayContains: self.teacher.uid)
		}
		
		query.addSnapshotListener { (snapshot: QuerySnapshot?, error: Error?) in
			if let snapshot = snapshot {
				let courses: [Course] = snapshot.documents.compactMap { (doc) in
					// Get document ID
					let uid = doc.documentID
					let data = doc.data()
					
					// Create course
					return Course(uid: uid, map: data)
				}
				
				self.activeCoursesSource.data = courses.filter({ !$0.archived })
				self.archivedCoursesSource.data = courses.filter({ $0.archived })
			} else {
				print(error!)
			}
		}
	}
	
	private func openCourse(course: Course) {
		
	}
	
}
