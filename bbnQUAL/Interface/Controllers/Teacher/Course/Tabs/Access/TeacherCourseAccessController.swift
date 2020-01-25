//
//  TeacherCourseAccessController.swift
//  bbnQUAL
//
//  Created by Dylan Hanson on 1/24/20.
//  Copyright © 2020 Jovialis. All rights reserved.
//

import Foundation
import UIKit
import TableManager
import SnapKit
import Firebase

class TeacherCourseAccessController: UIViewController {
	
	private var course: Course!
	private(set) var teachers: [TeamMember] = [] // Represents the most up-to-date list of teachers. Do not use the one in the course.
	
	private var tableView: UITableView!
	
	convenience init(course: Course) {
		self.init()
		self.course = course
		self.teachers = self.course.teachers
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// setup table
		self.setupViews()
		
		// Display teachers
		self.displayTeachers(teachers: self.teachers)
	}
	
	private func setupViews() {
		// Create table view
		self.tableView = UITableView()
		self.view.addSubview(self.tableView)
		
		// Constrain table view
		self.tableView.snp.makeConstraints { $0.edges.equalToSuperview() }
		
		// Configure table view
		self.tableView.separatorStyle = .none
	
		// Setup header
		let header = UIView()
		header.backgroundColor = .systemBackground
		
		let section = self.tableView.addSection()
		section.setHeaderView(withStaticView: header)
		section.setHeaderHeight(withStaticHeight: 82)
		
		// Add label
		let headerLabel = UILabel()
		headerLabel.text = "Teachers"
		headerLabel.font = UIFont(name: "PTSans-Regular", size: 32)
		
		header.addSubview(headerLabel)
		
		headerLabel.snp.makeConstraints { $0.leading.top.equalToSuperview() }
		
		// Add teachers button
		let addButton = UIButton(type: .contactAdd)
		addButton.tintColor = .label
		header.addSubview(addButton)
		
		addButton.snp.makeConstraints {
			$0.leading.equalTo(headerLabel.snp.trailing).offset(20)
			$0.centerY.equalTo(headerLabel.snp.centerY)
		}
		
		// Open add teacher controller when clicked
		addButton.onTouchUpInside.subscribe(with: self) {
			self.openAddController()
		}
	}
	
	private func displayTeachers(teachers: [TeamMember]) {
		self.tableView.clearRows()
		
		let ourUID = Auth.auth().currentUser!.uid
		
		// Row for each teacher
		teachers.forEach { (teacher: TeamMember) in
			
			// Handle teacher remove click
			let isUs = teacher.ref.documentID == ourUID
			
			// Add a row
			self.tableView.addRow()
				.setHeight(withStaticHeight: 100)
				.setConfiguration { (row: Row, cell: UITableViewCell, index: IndexPath) in
					
					// Disable click
					cell.selectionStyle = .none
					
					// Remove all cell subviews
					cell.subviews.forEach { $0.removeFromSuperview() }
					
					// Create teacher view
					let teacherView = TeacherView(teacher: teacher, actionLabel: "Remove", showAction: !isUs)
					cell.addSubview(teacherView)
					
					// Constrain
					teacherView.snp.makeConstraints { $0.edges.equalToSuperview() }

					// Handle click
					teacherView.actionButton.onTouchUpInside.cancelAllSubscriptions()
					teacherView.actionButton.onTouchUpInside.subscribe(with: self) {
						
						// If it's not us, attempt to remove the teacher from our teachers array. Then,
						// we save the array to the db
						if !isUs {
							self.teachers.removeAll { $0.ref.documentID == teacher.ref.documentID }
							
							// Reload our list
							self.displayTeachers(teachers: self.teachers)
							
							self.saveTeachers()
						}
						
					}
			}
			
		}
		
		// Reload
		self.tableView.reloadData()
	}
	
	// Adds a teacher to the array and saves it to the database
	func addTeacher(teacher: TeamMember) {
		// Add to our own list
		self.teachers.append(teacher)
		
		// Reload our list
		self.displayTeachers(teachers: self.teachers)
		
		// Save
		self.saveTeachers()
	}
	
	// Saves our array to the database
	private func saveTeachers() {
		// Save to database
		self.course.ref.updateData([
		
			// Map our teachers array to data
			"teacherRefs": self.teachers.map { teacher in
				
				return [
					
					"ref": teacher.ref,
					"name": teacher.name,
					"email": teacher.email
					
				]
				
			}
			
		]) { (error: Error?) in
			
			// Something went wrong if we have an error
			if let error = error {
				print(error)
				
				// Present a retry screen to the user
				self.present(ErrorRetryController(message: "Failed to save teachers.", onRetry: {
					
					// try again
					self.saveTeachers()
					
				}), animated: true, completion: nil)
			}
			
		}
	}
	
	private func openAddController() {
		// Instantiate from storyboard
		let storyboard = UIStoryboard(name: "TeacherCourseAccessAdd", bundle: nil)
		let addController = storyboard.instantiateInitialViewController() as! TeacherCourseAccessAddStoryboardController
		
		addController.controller = self
		addController.modalPresentationStyle = .pageSheet
		self.present(addController, animated: true, completion: nil)
	}
	
}
