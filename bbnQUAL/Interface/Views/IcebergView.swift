//
//  IcebergView.swift
//  bbnQUAL
//
//  Created by Dylan Hanson on 1/16/20.
//  Copyright © 2020 Jovialis. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class IcebergView: UIView {
	
	private var iceberg: Iceberg? { didSet { self.setNeedsLayout() } }
	
	private(set) var resolveButton: ActionButton!
	
	private var groupName: UILabel!
	private var membersLabel: UILabel!
	
	convenience init(iceberg: Iceberg) {
		self.init(frame: .zero)
		self.iceberg = iceberg
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		
		self.setupView()
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		self.setupView()
	}
	
	private func setupView() {
		// Create stack
		let stack = self.createMasterStack()
		
		// Create team stack
		let teamStack = self.createNamesStack()
		stack.addArrangedSubview(teamStack)
		
		// Resolve button
		self.resolveButton = self.createResolveButton()
		stack.addArrangedSubview(self.resolveButton)
	}
	
	private func createMasterStack() -> UIStackView {
		// Create stack
		let stack = UIStackView()
		stack.axis = .horizontal
		stack.distribution = .fill
		stack.alignment = .center
		
		self.addSubview(stack)
		
		// Constrain
		stack.snp.makeConstraints { $0.leading.trailing.top.bottom.equalToSuperview() }
		
		return stack
	}
	
	private func createNamesStack() -> UIStackView {
		// Create stack
		// Create stack
		let stack = UIStackView()
		stack.axis = .vertical
		stack.distribution = .equalSpacing
		stack.alignment = .leading
		
		// Team label
		let teamLabel = UILabel()
		teamLabel.text = ""
		teamLabel.font = UIFont(name: "PTSans-Regular", size: 24)
		teamLabel.textColor = .secondaryLabel
		self.groupName = teamLabel
		
		// Membersh label
		let membersLabel = UILabel()
		membersLabel.text = ""
		membersLabel.font = UIFont(name: "PTSans-Regular", size: 22)
		membersLabel.textColor = .tertiaryLabel
		self.membersLabel = membersLabel
		
		stack.addArrangedSubview(teamLabel)
		stack.addArrangedSubview(membersLabel)
		
		return stack
	}
	
	private func createResolveButton() -> ActionButton {
		// Create button
		let button = ActionButton(title: "Resolve", background: .label, text: .systemBackground)
		return button
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		guard let iceberg = self.iceberg else {
			return
		}
		
		self.groupName.text = iceberg.team.name
		self.membersLabel.text = iceberg.team.members.map({ $0.name }).joined(separator: ", ")
	}
	
}
