//
//  CourseView.swift
//  bbnQUAL
//
//  Created by Dylan Hanson on 12/14/19.
//  Copyright © 2019 Jovialis. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import Signals

class CourseView: UIView {

	// Represented course
	var course: Course? {
		didSet {
			self.setNeedsLayout()
		}
	}
	
	private var infoStack: UIStackView!
	
	private var courseNameLabel: UILabel!
	private var statusLabel: UILabel!
	private var teachersLabel: UILabel!
	
	private(set) var clickedButton: UIButton!
	
	convenience init(course: Course) {
		self.init()
		self.course = course
	}
	
	convenience init() {
		self.init(frame: .zero)
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.setupViews()
		
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.setupViews()
	}
	
	private func setupViews() {
		// Create stack
		self.setupStack()
		
		// Course name label
		let nameLabel = UILabel()
		self.infoStack.addArrangedSubview(nameLabel)
		self.courseNameLabel = nameLabel
		
		// Configure label
		nameLabel.font = UIFont(name: "PTSans-Regular", size: 24)
		
		// Archived label
		let statusLabel = UILabel()
		self.statusLabel = statusLabel
		self.addSubview(self.statusLabel)
		
		// Configure label
		statusLabel.font = UIFont(name: "PTSans-Regular", size: 20)
		
		// Constrain status label
		statusLabel.snp.makeConstraints { constrain in
			constrain.trailing.equalToSuperview().inset(20)
			constrain.centerY.equalTo(nameLabel.snp.centerY)
		}
		
		// Create teachers label
		let teachersLabel = UILabel()
		self.teachersLabel = teachersLabel
		self.infoStack.addArrangedSubview(teachersLabel)
		
		// Configure label
		teachersLabel.font = UIFont(name: "PTSans-Regular", size: 20)
		teachersLabel.textColor = .tertiaryLabel
		
		// Create clicked button
		let button = UIButton()
		button.setTitle(nil, for: .normal)
		
		self.addSubview(button)
		button.snp.makeConstraints { (constrain) in
			constrain.leading.equalToSuperview()
			constrain.trailing.equalToSuperview()
			constrain.top.equalToSuperview()
			constrain.bottom.equalToSuperview()
		}
		
		self.clickedButton = button
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		guard let course = self.course else {
			return
		}
		
		self.courseNameLabel!.text = course.name
		self.teachersLabel.text = "Taught by \((course.teachers.map { $0.name.split(separator: " ").last ?? "-" }).joined(separator: ", "))"
		
		self.statusLabel!.text = "\(course.status.displayName)"
		self.statusLabel.textColor = (course.status == .live ? UIColor(named: "Pink")! : .secondaryLabel)
	}
	
	private func setupStack() {
		// Set up stack view
		let stack = UIStackView()
		stack.alignment = .leading
		stack.axis = .vertical
	
		// Add subview
		self.addSubview(stack)
		
		// Constrain subview
		stack.snp.makeConstraints { (constrain) in
			// Sides
			constrain.leading.equalToSuperview().offset(20)
			
			// Center
			constrain.centerY.equalToSuperview()
		}
		
		self.infoStack = stack
	}
	
}

