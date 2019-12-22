//
//  ReagentSelectionView.swift
//  bbnQUAL
//
//  Created by Dylan Hanson on 12/22/19.
//  Copyright © 2019 Jovialis. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class ReagentSelectionView: UIView {
	
	private var setup: Bool = false
	
	// Content descriptions
	var tubeName: String = "XXXX"
	var reagentNames: [String] = [  ]
	
	// Closure used to determine which reagents are used
	var getUsedReagents: () -> [String] = { return [] }
	
	// Subviews
	private var mainStack: UIStackView!
	private var tubeStack: UIStackView!
	
	private var testTubeView: TestTubeView!
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		// Setup subviews if not already setup
		if !self.setup {
			self.setupSubviews()
			self.setup = true
		}
		
		self.updateSubviews()
	}
	
	// Layout subviews
	private func setupSubviews() {
		// Main stack view
		self.mainStack = UIStackView()
		
		// Configure main stack
		self.mainStack.alignment = .center
		self.mainStack.axis = .vertical
		self.mainStack.distribution = .equalSpacing
		self.mainStack.spacing = 40.0
		
		// Test tube display stack
		self.tubeStack = UIStackView()
		
		// Configure tube stack
		self.tubeStack.alignment = .center
		self.tubeStack.axis = .vertical
		self.tubeStack.distribution = .equalSpacing
		self.tubeStack.spacing = 10.0
		
		// Add tube stack subviews
		self.testTubeView = TestTubeView()
		
	}
	
	func updateSubviews() {
		
	}
	
}
