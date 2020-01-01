//
//  StudentGameFrozenViewController.swift
//  bbnQUAL
//
//  Created by Dylan Hanson on 12/28/19.
//  Copyright © 2019 Jovialis. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import Bond
import Firebase
import FirebaseFirestoreSwift
import SwiftyJSON

class StudentGameFrozenViewController: UIViewController {
			
	var icebergCode: String!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Background
		self.view.backgroundColor = .systemBackground

		// Layout subviews
		// Create stack view for labels
		let stack = UIStackView()
		self.view.addSubview(stack)

		// Configure stack
		stack.alignment = .center
		stack.axis = .vertical
		stack.spacing = 10

		// Constrain stack
		stack.snp.makeConstraints { constrain in
			constrain.center.equalToSuperview()
		}

		// Create labels
		let mainLabel = UILabel()
		stack.addArrangedSubview(mainLabel)

		let subLabel = UILabel()
		stack.addArrangedSubview(subLabel)
		
		// Configure labels
		mainLabel.text = "Check-In"
		subLabel.text = "A teacher will be with you shortly"

		mainLabel.font = UIFont(name: "PTSans-Bold", size: 40)
		subLabel.font = UIFont(name: "PTSans-Regular", size: 25)
		
		// Create continue button
		let button = UIButton()
		self.view.addSubview(button)
		
		// Listen for when the teacher clears the iceberg
		self.listenToChanges()
	}
	
	private func listenToChanges() {
		let docRef = Firestore.firestore().document(self.icebergCode)
		docRef.addSnapshotListener { (snapshot: DocumentSnapshot?, error: Error?) in
			if let snapshot = snapshot {
				if snapshot.exists, let data = snapshot.data() {
					
					// Check whether the issue is resolved
					if let resolved = data["resolved"] as? Bool {
						if resolved {
							self.resolve()
						}
					}
					
				}
			} else {
				print(error!)
			}
		}
	}
	
	private func resolve() {
		// Pop from stack if presented in nav controller, otherwise dismiss
		if let navigationController = self.navigationController {
			navigationController.popViewController(animated: false)
		} else {
			self.dismiss(animated: true, completion: nil)
		}
	}
	
}
