//
//  TeacherCourseSessionProgressController.swift
//  bbnQUAL
//
//  Created by Dylan Hanson on 1/13/20.
//  Copyright © 2020 Jovialis. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import Firebase
import TableManager

class TeacherCourseSessionProgressController: UIViewController {
	
	private var course: Course!
	
	private var loading: UIActivityIndicatorView!
	private var masterStack: UIStackView!
	private var tableView: UITableView!
	
	private var progressionCollectionListener: ListenerRegistration!

	convenience init(course: Course) {
		self.init()
		self.course = course
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Setup
		self.setupLoading()
		self.setupMasterStack()
		
		// Observe changes in the sessions document
		self.observeChangesInProgressionsCollection()
	}
	
	private func setupLoading() {
		self.loading = UIActivityIndicatorView()
		self.view.addSubview(self.loading)
		
		self.loading.hidesWhenStopped = true
		self.loading.startAnimating()
		
		// Constrain
		self.loading.snp.makeConstraints { (constrain: ConstraintMaker) in
			constrain.center.equalToSuperview()
		}
	}
	
	private func setupMasterStack() {
		// Stack
		self.masterStack = UIStackView()
		self.view.addSubview(self.masterStack)
		
		// Configure stack
		self.masterStack.axis = .vertical
		self.masterStack.distribution = .fill
		self.masterStack.spacing = 10
		self.masterStack.alignment = .fill
		
		// Constrain
		self.masterStack.snp.makeConstraints { (constrain: ConstraintMaker) in
			constrain.leading.trailing.top.bottom.equalToSuperview()
		}
		
		self.masterStack.isOpaque = true
		self.masterStack.backgroundColor = .green
		
		// Add label
		let label = UILabel()
		label.text = "Team Progressions"
		label.font = UIFont(name: "PTSans-Bold", size: 32)
		self.masterStack.addArrangedSubview(label)
		
		// Add table view
		self.tableView = UITableView()
		self.tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
		self.tableView.separatorStyle = .none
		self.masterStack.addArrangedSubview(self.tableView)
	}
	
	// Observe changes in sessions collection. If we find one, attempt to re-fetch a session
	private func observeChangesInProgressionsCollection() {
		// Reference
		let collectionRef = self.course.ref.collection("progressions")
		self.progressionCollectionListener = collectionRef
			.addSnapshotListener { (snapshot: QuerySnapshot?, error: Error?) in
			
			self.loading.stopAnimating()
				
			if let snapshot = snapshot {
				
				// Load documents into memory
				var progressions = snapshot.documents.compactMap { (snapshot: QueryDocumentSnapshot) -> TeacherProgressionOverview? in
					
					// Parse iceberg
					let json = JSONObject(snapshot.data())
					
					return TeacherProgressionOverview(ref: snapshot.reference, json: json)
					
				}
				
				// Put finished progressions at the end
				progressions.sort { (a, _) in !a.finished }
				
				// Update our table view
				self.updateTable(with: progressions)
				
			} else {
				
				print(error!)
				
			}
				
		}

	}
	
	// Update the table
	private func updateTable(with progressions: [TeacherProgressionOverview]) {
		// Remove all rows
		self.tableView.clearRows()
				
		// Create a row for each timestamp
		progressions.forEach { (progression: TeacherProgressionOverview) in
			
			// Create a row
			self.tableView
				.addRow()
				.setHeight(withStaticHeight: 100)
				.setConfiguration { (row: Row, cell: UITableViewCell, path: IndexPath) in
				
					// Configure cell
					cell.selectionStyle = .none
					
					// Remove all child views from the cell
					cell.contentView.subviews.forEach { $0.removeFromSuperview() }
						
					// Add iceberg view
					let progressionView = ProgressionTrackView(progression: progression, course: self.course)
					cell.contentView.addSubview(progressionView)
				
					// Constrain iceberg view
					progressionView.snp.makeConstraints {
						$0.leading.trailing.top.bottom.equalToSuperview()
					}
				
			}
			
			self.tableView.addSpace(height: 20, bgColor: .systemBackground)
			
		}
		
		// Add label row
		self.tableView
			.addRow()
			.setHeight(withStaticHeight: 100)
			.setConfiguration { (row: Row, cell: UITableViewCell, path: IndexPath) in
			
				// Configure cell
				cell.selectionStyle = .none
				
				// Remove all child views from the cell
				cell.contentView.subviews.forEach { $0.removeFromSuperview() }
					
				// Add iceberg view
				let progressionView = ProgressionTrackLabelView(course: self.course)
				cell.contentView.addSubview(progressionView)
			
				// Constrain iceberg view
				progressionView.snp.makeConstraints {
					$0.leading.trailing.top.bottom.equalToSuperview()
				}
			
		}
		
		// Reload
		self.tableView.reloadData()
	}
	
}
