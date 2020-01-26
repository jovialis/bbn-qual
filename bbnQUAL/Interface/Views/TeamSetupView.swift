//
//  TeamSetupView.swift
//  bbnQUAL
//
//  Created by Dylan Hanson on 1/25/20.
//  Copyright © 2020 Jovialis. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class TeamSetupView: UIView, UITextFieldDelegate {
	
	private var controller: TeacherCourseTeamsController!
	
	private var team: SetupTeam!
	
	private var titleField: UITextField!
	private var membersLabel: UILabel!
	private var membersStack: UIStackView!
	private var addMemberField: UITextField!
	
	convenience init(team: SetupTeam, controller: TeacherCourseTeamsController) {
		self.init()
		self.team = team
		self.controller = controller
	}
	
	convenience init() {
		self.init(frame: .zero)
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.doSetup()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.doSetup()
	}
	
	private func doSetup() {
		// background
		self.backgroundColor = .systemFill
		
		// stack
		let masterStack = UIStackView()
		self.addSubview(masterStack)
		
		// configure
		masterStack.axis = .vertical
		masterStack.spacing = 10
		masterStack.alignment = .fill
		masterStack.distribution = .fill
		
		// Constrain
		masterStack.snp.makeConstraints { $0.leading.trailing.top.bottom.equalToSuperview() }
		
		// Name label
		let teamName = UILabel()
		teamName.text = "Team Name"
		masterStack.addArrangedSubview(teamName)
		
		// Name field
		self.titleField = UITextField()
		self.titleField.placeholder = "Team Name"
		self.titleField.backgroundColor = .secondarySystemFill
		masterStack.addArrangedSubview(self.titleField)
		
		self.titleField.onEditingChanged.subscribe(with: self) {
			self.team.setName(to: self.titleField.text ?? "-")
			self.controller.attemptSave()
		}
		
		// Members label
		self.membersLabel = UILabel()
		masterStack.addArrangedSubview(self.membersLabel)
		
		// Members stack
		self.membersStack = UIStackView()
		masterStack.addArrangedSubview(self.membersStack)
		
		// Members stack configure
		self.membersStack.axis = .vertical
		self.membersStack.spacing = 5
		self.membersStack.distribution = .fill
		
		// text field
		self.addMemberField = UITextField()
		masterStack.addArrangedSubview(self.addMemberField)
		self.addMemberField.placeholder = "Add member email"
		self.addMemberField.backgroundColor = .secondarySystemFill
		
		// configure
		self.addMemberField.delegate = self
		
		// Remove button
		let removeButton = UIButton()
		removeButton.setTitle("Delete Team", for: .normal)
		masterStack.addArrangedSubview(removeButton)
		
		removeButton.onTouchUpInside.subscribe(with: self) {
			self.controller.removeTeam(team: self.team)
		}
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		let text = textField.text ?? ""
		
		if text.trimmingCharacters(in: .whitespaces).isEmpty {
			return false
		}
		
		// Remove email from other teams
		self.controller.removeEmailFromTeams(email: text)
		
		// Add email
		self.team.insert(email: text)
		self.layoutSubviews()
		self.controller.attemptSave()
		
		textField.text = nil
		return true
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		self.titleField.text = self.team.name
		self.membersLabel.text = "Team Members (\( self.team.emails.count ))"
		
		// Remove all member views
		self.membersStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
		
		// Add new member views
		self.team.emails.forEach {
			self.membersStack.addArrangedSubview(self.generateMemberView(email: $0))
		}
	}
	
	private func generateMemberView(email: String) -> UIView {
		// Create view
		let view = UIView()
		view.layer.borderColor = UIColor.secondarySystemFill.cgColor
		
		// Create label
		let label = UILabel()
		view.addSubview(label)
		
		label.text = email
		
		// Constrain
		label.snp.makeConstraints { $0.edges.equalToSuperview() }
		
		// Button
		let removeButton = UIButton()
		removeButton.setTitle("Remove", for: .normal)
		
		view.addSubview(removeButton)
		
		removeButton.snp.makeConstraints { $0.centerY.trailing.equalToSuperview() }
		
		removeButton.onTouchUpInside.subscribe(with: self) {
			self.team.remove(email: email)
			self.setNeedsLayout()
			self.controller.attemptSave()
		}
		
		return view
	}
	
}
