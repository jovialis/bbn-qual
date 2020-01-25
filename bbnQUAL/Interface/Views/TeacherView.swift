//
//  TeacherView.swift
//  bbnQUAL
//
//  Created by Dylan Hanson on 1/24/20.
//  Copyright © 2020 Jovialis. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class TeacherView: UIView {
	
	private var teacher: TeamMember! { didSet { self.setNeedsLayout() } }
	private var actionLabel: String! { didSet { self.setNeedsLayout() } }
	private var showRemove: Bool! { didSet { self.setNeedsLayout() } }
	
	private var nameLabel: UILabel!
	private var emailLabel: UILabel!
	
	private(set) var actionButton: ActionButton!
	
	convenience init(teacher: TeamMember, actionLabel: String, showAction: Bool) {
		self.init(frame: .zero)
		self.teacher = teacher
		self.actionLabel = actionLabel
		self.showRemove = showAction
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.setupView()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.setupView()
	}
	
	private func setupView() {
		// Create stack
		let stack = UIStackView()
		stack.axis = .vertical
		stack.alignment = .leading
		stack.spacing = 10
		self.addSubview(stack)
		
		// Constrain
		stack.snp.makeConstraints { $0.leading.trailing.centerY.equalToSuperview() }
	
		// Teacher name
		self.nameLabel = UILabel()
		self.nameLabel.font = UIFont(name: "PTSans-Regular", size: 24)
		self.nameLabel.textColor = .secondaryLabel
		stack.addArrangedSubview(self.nameLabel)
		
		// Teacher email
		self.emailLabel = UILabel()
		self.emailLabel.font = UIFont(name: "PTSans-Regular", size: 20)
		self.emailLabel.textColor = .tertiaryLabel
		stack.addArrangedSubview(self.emailLabel)
		
		// Remove teacher
		self.actionButton = ActionButton(title: "Remove", background: .secondaryLabel, text: .systemBackground)
		self.addSubview(self.actionButton)
		
		// Constrain remove button
		self.actionButton.snp.makeConstraints { $0.trailing.centerY.equalToSuperview() }
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		// Update labels
		self.nameLabel.text = self.teacher.name
		self.emailLabel.text = self.teacher.email
		
		self.actionButton.setTitle(self.actionLabel, for: .normal)
		self.actionButton.isHidden = !self.showRemove
	}
	
}
