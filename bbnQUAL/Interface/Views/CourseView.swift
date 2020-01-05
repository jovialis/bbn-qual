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
	
	var infoStack: UIStackView?
	
	var courseNameLabel: UILabel?
	var archivedLabel: UILabel?
	
	var clickedButton: UIButton?
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		// Set subviews if they don't exist already
		if self.infoStack == nil {
			self.setupStack()
		}
		
		if self.courseNameLabel == nil {
			let label = UILabel()
			self.infoStack!.addArrangedSubview(label)
			self.courseNameLabel = label
		}
		
		if self.archivedLabel == nil {
			let label = UILabel()
			self.infoStack!.addArrangedSubview(label)
			self.archivedLabel = label
		}
		
		if self.clickedButton == nil {
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
		
		self.updateContent()
	}
	
	private func setupStack() {
		// Set up stack view
		let stack = UIStackView()
		stack.alignment = .center
		stack.axis = .vertical
	
		// Add subview
		self.addSubview(stack)
		
		// Constrain subview
		stack.snp.makeConstraints { (constrain) in
			// Sides
			constrain.leading.greaterThanOrEqualToSuperview()
			constrain.trailing.greaterThanOrEqualToSuperview()
			
			// Center
			constrain.centerX.equalToSuperview()
			constrain.centerY.equalToSuperview()
		}
		
		self.infoStack = stack
	}
	
	private func updateContent() {
		if self.courseNameLabel != nil {
			self.courseNameLabel!.text = self.course?.name
		}

		if self.archivedLabel != nil {
			self.archivedLabel!.text = "\(self.course!.archived)"
		}
	}
	
}

