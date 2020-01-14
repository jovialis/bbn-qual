//
//  ProgressionTrackView.swift
//  bbnQUAL
//
//  Created by Dylan Hanson on 1/14/20.
//  Copyright © 2020 Jovialis. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class ProgressionTrackView: UIView {
	
	/* ALL CONFIG VARIABLES TRIGGER LAYOUT UPDATES WHEN CHANGED */
	
	// Team finished
	var finished: Bool = false { didSet { self.setNeedsLayout() } }
	
	// Number required
	var assignBeginner: Bool = true { didSet { self.setNeedsLayout() } }
	var numRegular: Int = 3 { didSet { self.setNeedsLayout() } }
	var numChallenge: Int = 2 { didSet { self.setNeedsLayout() } }
	
	// Group information
	var groupName: String = "" { didSet { self.setNeedsLayout() } }
	var members: [String] = [] { didSet { self.setNeedsLayout() } }
	
	// Assigned items information. This is the sum of all completed groups
	// and any currently assigned groups.
	var assignedBeginner: Bool = false { didSet { self.setNeedsLayout() } }
	var assignedRegular: [String] = [] { didSet { self.setNeedsLayout() } }
	var assignedChallenge: [String] = [] { didSet { self.setNeedsLayout() } }
	
	// VIEWS
	fileprivate var teamLabel: UILabel!
	fileprivate var teamMembersLabel: UILabel!
	fileprivate var groupMarkerStack: UIStackView!
	fileprivate var progressLine: UIView!
	
	private let markerWidth: Int = 30
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.doInit()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.doInit()
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		// Update content on layout
		self.updateContent()
	}
	
	fileprivate func doInit() {
		// Create master stack. Subviews: team stack, markers stack
		let stack = UIStackView()
		self.addSubview(stack)
		
		// Configure stack
		stack.distribution = .fill
		stack.alignment = .center
		
		// Constrain stack to our edges
		stack.snp.makeConstraints { $0.leading.trailing.top.bottom.equalToSuperview() }
		
		// Get the team info stack
		let teamStackTuple = self.generateTeamInfoStack()
		stack.addArrangedSubview(teamStackTuple.stack)
		
		self.teamLabel = teamStackTuple.teamLabel
		self.teamMembersLabel = teamStackTuple.membersLabel
		
		// Constrain the max width of the team stack to 1/6 of our size
		teamStackTuple.stack.snp.makeConstraints { $0.width.equalToSuperview().dividedBy(6) }
		
		// Get the group marker stack
		let groupMarkerStack = self.generateGroupMarkerStack()
		stack.addArrangedSubview(groupMarkerStack)
		self.groupMarkerStack = groupMarkerStack
		
		// Progress line
		self.progressLine = self.generateProgressLine()
		self.addSubview(self.progressLine)
		self.progressLine.layer.zPosition = -5
		
		// Constrain progress line
		self.progressLine.snp.makeConstraints { constrain in
			constrain.leading.equalTo(self.groupMarkerStack.snp.leading)
			constrain.centerY.equalTo(self.groupMarkerStack.snp.centerY)
		}
	}
	
	// Generates the stack for the user group
	fileprivate func generateTeamInfoStack() -> (
		stack: UIStackView,
		teamLabel: UILabel,
		membersLabel: UILabel
	) {
		// Create stack
		let stack = UIStackView()
		stack.axis = .vertical
		stack.alignment = .leading
		stack.distribution = .equalCentering
		stack.spacing = 5
		
		// Add group label
		let groupLabel = UILabel()
		groupLabel.textColor = .secondaryLabel
		groupLabel.font = UIFont(name: "PTSans-Regular", size: 22)
		
		stack.addArrangedSubview(groupLabel)
		
		// Add members label
		let membersLabel = UILabel()
		membersLabel.textColor = .tertiaryLabel
		membersLabel.font = UIFont(name: "PTSans-Regular", size: 18)
		
		stack.addArrangedSubview(membersLabel)
		
		return (stack: stack, teamLabel: groupLabel, membersLabel: membersLabel)
	}

	// Generates a stack for laying out the group markers
	fileprivate func generateGroupMarkerStack() -> UIStackView {
		let stack = UIStackView()
		stack.alignment = .center
		stack.axis = .horizontal
		stack.distribution = .equalSpacing
		return stack
	}
	
	fileprivate func updateContent() {
		// Update team info
		self.teamLabel.text = self.groupName
		self.teamMembersLabel.text = self.members.joined(separator: ", ")
		
		// Wipe all currently laid out markers
		self.groupMarkerStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
		
		var lastRealMarker: UIView?
		
		// Create a marker for the beginner group
		if self.assignBeginner {
			// We always want to create a real marker for beginner
			let beginnerMarker = self.generateGroupMarker(groupName: "0")
			self.groupMarkerStack.addArrangedSubview(beginnerMarker)
			
			lastRealMarker = beginnerMarker
		}
		
		// Create markers for regular groups
		for iR in 0..<self.numRegular {
			var generatedGroup: UIView
			
			// If this group has been assigned
			if iR < self.assignedRegular.count {
				let completedGroup = self.assignedRegular.item(at: iR)
				generatedGroup = self.generateGroupMarker(groupName: completedGroup)
				
				lastRealMarker = generatedGroup
			} else {
				generatedGroup = self.generateNullGroupMarker()
			}
			
			self.groupMarkerStack.addArrangedSubview(generatedGroup)
		}
		
		// Create markers for challenge groups
		for iC in 0..<self.numChallenge {
			var generatedGroup: UIView
			
			// If this group has been assigned
			if iC < self.assignedChallenge.count {
				let completedGroup = self.assignedChallenge.item(at: iC)
				generatedGroup = self.generateGroupMarker(groupName: completedGroup)
				
				lastRealMarker = generatedGroup
			} else {
				generatedGroup = self.generateNullGroupMarker()
			}
			
			self.groupMarkerStack.addArrangedSubview(generatedGroup)
		}
		
		// Create finished marker
		if self.finished {
			let finishedShield = self.generateFinishedShield()
			self.groupMarkerStack.addArrangedSubview(finishedShield)
			
			lastRealMarker = finishedShield
		} else {
			self.groupMarkerStack.addArrangedSubview(self.generateNullGroupMarker())
		}
		
		// Progress line
		if let lastRealMarker = lastRealMarker {
			self.progressLine.snp.makeConstraints { $0.trailing.equalTo(lastRealMarker.snp.centerX) }
		}
	}
	
	// Generates a marker to represent a given reagent group
	fileprivate func generateGroupMarker(groupName: String) -> UIView {
		// Create view
		let view = UIView()
		view.backgroundColor = UIColor.label.withAlphaComponent(1)
		
		// Constrain to 24x24
		view.snp.makeConstraints { $0.height.width.equalTo(self.markerWidth) }
		
		// Create label
		let label = UILabel()
		label.font = UIFont(name: "PTSans-Regular", size: 22)
		label.textColor = .systemBackground
		
		label.text = groupName
		
		// Add label to view
		view.addSubview(label)
		
		// Constrain label to center
		label.snp.makeConstraints { $0.center.equalToSuperview() }
		
		return view
	}
	
	// Generates a blank marker
	fileprivate func generateNullGroupMarker() -> UIView {
		// Create view
		let view = UIView()
		view.backgroundColor = .clear
		
		// Constrain to 24x24
		view.snp.makeConstraints { $0.height.width.equalTo(self.markerWidth) }
		
		return view
	}
	
	// Generates the finished shield
	fileprivate func generateFinishedShield() -> UIView {
		// Create view
		let view = UIView()
		view.backgroundColor = .clear
		
		view.snp.makeConstraints { constrain in
			constrain.height.equalTo(self.markerWidth + 14)
			constrain.width.equalTo(self.markerWidth)
		}

		// Create image
		let shield = UIImage(systemName: "shield.fill", withConfiguration: UIImage.SymbolConfiguration(weight: .black))!
		let greenShield = shield.withTintColor(UIColor(named: "Green")!, renderingMode: .alwaysOriginal)
		
		// Image view
		let imageView = UIImageView(image: greenShield)
		imageView.contentMode = .scaleAspectFill
		imageView.clipsToBounds = false
		
		// Add subview
		view.addSubview(imageView)
		
		// Constrain
		imageView.snp.makeConstraints { $0.leading.trailing.bottom.top.equalToSuperview() }
		
		// Check mark
		let check = UIImage(systemName: "checkmark", withConfiguration: UIImage.SymbolConfiguration(weight: .black))!
		let whiteCheck = check.withTintColor(.white, renderingMode: .alwaysOriginal)

		// Image view
		let checkImageView = UIImageView(image: whiteCheck)
		checkImageView.contentMode = .scaleAspectFit
		
		imageView.addSubview(checkImageView)
		checkImageView.snp.makeConstraints { constrain in
			constrain.center.equalToSuperview()
			constrain.width.equalToSuperview().dividedBy(1.2)
		}
		
		return view
	}
	
	// Generates a progress line
	fileprivate func generateProgressLine() -> UIView {
		// Create view
		let view = UIView()
		view.backgroundColor = UIColor(named: "Pink")!
		
		view.snp.makeConstraints { $0.height.equalTo(8)}
		
		return view
	}
	
}

class ProgressionTrackLabelView: ProgressionTrackView {
		
	override fileprivate func updateContent() {
		// Update team info
		self.teamLabel.text = ""
		self.teamMembersLabel.text = ""
		
		// Wipe all currently laid out markers
		self.groupMarkerStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
				
		// Create a marker for the beginner group
		if self.assignBeginner {
			let labelStack = self.generateLabelStack(num: 0, difficulty: .practice)
			self.groupMarkerStack.addArrangedSubview(labelStack)
		}
		
		// Create markers for regular groups
		for iR in 0..<self.numRegular {
			let labelStack = self.generateLabelStack(num: iR + 1, difficulty: .regular)
			self.groupMarkerStack.addArrangedSubview(labelStack)
		}
		
		// Create markers for challenge groups
		for iC in 0..<self.numChallenge {
			let labelStack = self.generateLabelStack(num: self.numRegular + iC + 1, difficulty: .challenge)
			self.groupMarkerStack.addArrangedSubview(labelStack)
		}
		
		// Add a blank label to substitute for the finished shield
		self.groupMarkerStack.addArrangedSubview(self.generateNullGroupMarker())
	}

	private func generateLabelStack(num: Int, difficulty: ProgressionDifficulty) -> UIView {
		let blankView = self.generateNullGroupMarker()
		
		// Create view
		let stack = UIStackView()
		stack.axis = .vertical
		stack.alignment = .center
		
		// Number label
		let numLabel = UILabel()
		numLabel.textColor = .secondaryLabel
		numLabel.font = UIFont(name: "PTSans-Regular", size: 18)
		numLabel.text = "\( num )"
		
		stack.addArrangedSubview(numLabel)
		
		// Difficulty label
		let difficultyLabel = UILabel()
		difficultyLabel.textColor = .tertiaryLabel
		difficultyLabel.font = UIFont(name: "PTSans-Regular", size: 18)
		difficultyLabel.text = difficulty.displayName
		
		stack.addArrangedSubview(difficultyLabel)
		
		// Add the stack to self directly then center on the blank view.
		// That way everythign lines up and there's no offset from the above tracks
		
		blankView.clipsToBounds = false
		blankView.addSubview(stack)
		
		stack.snp.makeConstraints { $0.center.equalToSuperview() }
		
		return blankView
	}
	
}
