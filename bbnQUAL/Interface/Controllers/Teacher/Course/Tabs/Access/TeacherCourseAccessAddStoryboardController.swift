//
//  TeacherCourseAccessAddStoryboardController.swift
//  bbnQUAL
//
//  Created by Dylan Hanson on 1/24/20.
//  Copyright © 2020 Jovialis. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import TableManager

class TeacherCourseAccessAddStoryboardController: UIViewController {
	
	var controller: TeacherCourseAccessController!
	
	@IBOutlet weak var textField: UITextField!
	@IBOutlet weak var tableView: UITableView!
	
	// Timer representing the 1/2 second delay between typing ending and fetching
	private var loadingTimer: Timer!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Listen to text field
		self.listenToTextField()
	}
	
	private func listenToTextField() {
		// On text field value changed
		self.textField.onEditingChanged.subscribe(with: self) {
			self.attemptFetchTeachers()
		}
	}
	
	private func attemptFetchTeachers() {
		// Cancel previous timer
		if let timer = self.loadingTimer {
			timer.invalidate()
		}
		
		// Create new timer
		self.loadingTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { _ in
			
			// Grab text
			let text = self.textField.text ?? ""
			
			// Don't search if the search string is empty
			if text.trimmingCharacters(in: .whitespaces).isEmpty {
				return
			}
			
			// Get teachers
			self.getTeachers(name: text).then(listener: self) {
				switch $0 {
				case .success(let teachers):
					self.updateTable(with: teachers)
					
				case .failure(let error):
					print(error)
					
					// Present failure controller
					self.present(ErrorRetryController(message: "Failed to fetch teachers.", onRetry: {
						
						self.attemptFetchTeachers()
						
					}), animated: true, completion: nil)
				}
			}
			
		})
	}
	
	private func updateTable(with teachers: [TeamMember]) {
		// Clear table rows
		self.tableView.clearRows()
		
		// Row for each teacher
		teachers.forEach { (teacher: TeamMember) in
			
			// Add a row
			self.tableView.addRow()
				.setHeight(withStaticHeight: 100)
				.setConfiguration { (row: Row, cell: UITableViewCell, index: IndexPath) in
					
					// Disable click
					cell.selectionStyle = .none
					
					// Remove all cell subviews
					cell.subviews.forEach { $0.removeFromSuperview() }
					
					// Create teacher view
					let teacherView = TeacherView(teacher: teacher, actionLabel: "Add", showAction: true)
					cell.addSubview(teacherView)
					
					// Constrain
					teacherView.snp.makeConstraints { $0.edges.equalToSuperview() }

					// Handle click
					teacherView.actionButton.onTouchUpInside.cancelAllSubscriptions()
					teacherView.actionButton.onTouchUpInside.subscribe(with: self) {
						
						// Trigger parent controller add
						self.controller.addTeacher(teacher: teacher)
						
						// Reset field
						self.textField.text = ""
						
						// Visually remove from list of options
						var newList = teachers
						newList.remove(at: index.row)
						
						self.updateTable(with: newList)
					}
			}
			
		}
		
		// Reload
		self.tableView.reloadData()
	}
	
	private func getTeachers(name: String) -> CallbackSignal<[TeamMember]> {
		let callback = CallbackSignal<[TeamMember]>()
		
		// Find reference
		let collection = Firestore.firestore().collection("users")
		collection
			.whereField("access", isEqualTo: 1)
			.whereField("nameLower", startsWith: name.lowercased())
			.getDocuments { (snapshot: QuerySnapshot?, error: Error?) in
			
			if let snapshot = snapshot {
				
				print(snapshot.documents)
				
				// Parse users
				var users = snapshot.documents.compactMap { TeamMember(ref: $0.reference, json: JSONObject($0.data())) }
				
				// Filter out users who are already in the course
				users.removeAll { toRemove in
					self.controller.teachers.contains(where: { toRemove.ref.documentID == $0.ref.documentID })
				}
				
				callback.fire(.success(object: users))
			} else {
				print(error!)
				callback.fire(.failure(error: error!))
			}
			
		}
		
		return callback
	}
	
	@IBAction func doneButtonClicked(_ sender: UIButton) {
		self.dismiss(animated: true, completion: nil)
	}
}
