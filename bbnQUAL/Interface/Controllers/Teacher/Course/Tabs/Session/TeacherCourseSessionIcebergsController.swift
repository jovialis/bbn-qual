//
//  TeacherCourseSessionIcebergsController.swift
//  bbnQUAL
//
//  Created by Dylan Hanson on 1/13/20.
//  Copyright © 2020 Jovialis. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import TableManager
import Firebase
import FirebaseFirestoreSwift

class TeacherCourseSessionIcebergsController: UIViewController {
	
	private var course: Course!
	
	private var loading: UIActivityIndicatorView!
	private var masterStack: UIStackView!
	private var tableView: UITableView!
	
	private var icebergCollectionListener: ListenerRegistration!

	convenience init(course: Course) {
		self.init()
		self.course = course
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Setup
		self.setupLoading()
		self.setupMasterStack()

		
//		// Handle changes in the session
//		self.observeSessionAndUpdateViews()
//
		// Observe changes in the sessions document
		self.observeChangesInIcebergCollection()
	}
	
	override func updateViewConstraints() {
		super.updateViewConstraints()
		
		// Constrain own view height
		self.view.snp.makeConstraints { (constrain: ConstraintMaker) in
			constrain.width.equalToSuperview().dividedBy(4)
		}
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
		
		// Add label
		let label = UILabel()
		label.text = "Check Ins"
		label.font = UIFont(name: "PTSans-Bold", size: 32)
		self.masterStack.addArrangedSubview(label)
		
		// Add table view
		self.tableView = UITableView()
		self.tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
		self.tableView.separatorStyle = .none
		self.masterStack.addArrangedSubview(self.tableView)
		
		// Constrain
		self.masterStack.snp.makeConstraints { (constrain: ConstraintMaker) in
			constrain.leading.trailing.top.bottom.equalToSuperview()/*.inset(25)*/
		}
	}
	
	// Observe changes in sessions collection. If we find one, attempt to re-fetch a session
	private func observeChangesInIcebergCollection() {
		// Reference
		let collectionRef = self.course.ref.collection("icebergs")
		self.icebergCollectionListener = collectionRef
			.whereField("resolved", isEqualTo: false)
			.addSnapshotListener { (snapshot: QuerySnapshot?, error: Error?) in
				
			if let snapshot = snapshot {
				
				// Load documents into memory
				var icebergs = snapshot.documents.compactMap { (snapshot: QueryDocumentSnapshot) -> Iceberg? in
					
					// Parse iceberg
					let data = snapshot.data()
					return Iceberg(ref: snapshot.reference, json: JSONObject(data))
					
				}
								
				// Sort by timestamp
				icebergs.sort { $0.timestamp.seconds < $1.timestamp.seconds }
				
				// Update our table view
				self.updateTable(with: icebergs)
				
			} else {
				
				print(error!)
				
			}
				
		}
	}
	
	// Update the table
	private func updateTable(with icebergs: [Iceberg]) {
		// Remove all rows
		self.tableView.clearRows()
		
		// Create a row for each timestamp
		icebergs.forEach { (iceberg: Iceberg) in
			
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
					let icebergView = IcebergView(iceberg: iceberg)
					cell.contentView.addSubview(icebergView)
									
					// Constrain iceberg view
					icebergView.snp.makeConstraints {
						$0.leading.trailing.top.bottom.equalToSuperview()
					}
					
					// On click resolve
					icebergView.resolveButton.onTouchUpInside.subscribe(with: self) {
						if !icebergView.resolveButton.loading {
							icebergView.resolveButton.showLoading()
							
							// Resolve
							self.resolve(iceberg: iceberg)
						}
					}
					
			}
						
		}
		
		self.tableView.reloadData()
	}
	
	private func resolve(iceberg: Iceberg) {
		// Update database
		iceberg.ref.updateData([ "resolved": true ]) { (error: Error?) in
			
			if let error = error {
				print(error)
			}
			
		}
	}
	
}
