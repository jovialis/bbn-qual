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
import Bond
import ReactiveKit
import CollectionKit

class ReagentSelectionView: UIView {
	
	static let REAGANT_BUTTON_HEIGHT: CGFloat = 50
	static let REAGANT_BUTTON_PADDING_HEIGHT: CGFloat = 5
	
	private var setup: Bool = false
	
	var index: Int = -1
	
	// Content descriptions
	var tubeName: String = "XXXX" {
		didSet {
			if let tube = self.testTubeView {
				tube.label = tubeName
			}
		}
	}
	
	var selectionWrapper: ReagentSelectionWrapper = EmptyReagentSelectionWrapper() {
		didSet {
			if let collection = self.collectionView {
				collection.reloadData()
				self.updateCollectionHeight()
			}
		}
	}
		
	// Subviews
	private var testTubeView: TestTubeView!
	private var collectionView: CollectionView!
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		// Setup subviews if not already setup
		if !self.setup {
			self.setupSubviews()
		}
		
		self.collectionView!.reloadData()
	}
	
	// Layout subviews
	private func setupSubviews() {
		self.setup = true

		// Test tube display stack
		let mainStack = UIStackView()
		
		// Configure horizontal grouping stack
		mainStack.alignment = .center
		mainStack.axis = .horizontal
		mainStack.distribution = .fill
		mainStack.spacing = 50
		
		// Add tube stack subviews
		self.testTubeView = TestTubeView()
		self.testTubeView.label = self.tubeName
		
		// Constrain
		self.testTubeView.snp.makeConstraints { constrain in
			constrain.height.equalTo(175)
			constrain.width.equalTo(60)
		}

		// Button container view
		let collectionView = CollectionView()
		self.collectionView = collectionView

		// Configure collection view
		let dataSource = ArrayDataSource(data: self.selectionWrapper.reagents)

		// View source
		let viewSource = ClosureViewSource { (button: UIButton, reagent: Reagent, index: Int) in
			// Configure button
			button.layoutSubviews()
			button.backgroundColor = .red
			
			// Button text
			button.contentEdgeInsets = UIEdgeInsets(top: 10.0, left: 0.0, bottom: 10.0, right: 0.0)
			
			// Default outline
			button.layer.borderColor = UIColor.systemFill.cgColor
			button.layer.borderWidth = 1.0
			
			let buttonTitle: String = reagent.name
			let buttonFont: UIFont = UIFont(name: "PTSans-Regular", size: 20.0)!
			var buttonColor: UIColor = .label
			
			// Update button state
			if self.selectionWrapper.isSelected(reagent) {
				// If it's this view, show selected. Otherwise, show unavailable
				if self.selectionWrapper.isAtIndex(reagent, index: self.index) {
					// Block color selected
					button.backgroundColor = .label
					buttonColor = .systemBackground
				} else {
					// Not available
					button.backgroundColor = .quaternarySystemFill
					buttonColor = .quaternaryLabel
				}
				
				button.layer.borderWidth = 0.0
			} else {
				// Default value
				button.backgroundColor = .systemBackground
			}
			
			let attributedString = self.buildButtonDisplay(title: buttonTitle, font: buttonFont, color: buttonColor)
			button.setAttributedTitle(attributedString, for: .normal)
			
			// Selection handlers
			_ = button.reactive.tapGesture().observe { _ in
				// If it's our selected reagent, unselect
				if self.selectionWrapper.isAtIndex(reagent, index: self.index) {
					self.selectionWrapper.unselect(reagent)
				} else { // Otherwise, select it
					self.selectionWrapper.setIndex(reagent, index: self.index)
				}
			}
		}
		
		// Button sizes
		let sizeSource = { (index: Int, data: Reagent, collectionSize: CGSize) -> CGSize in
			return CGSize(width: 125, height: ReagentSelectionView.REAGANT_BUTTON_HEIGHT)
		}
		
		// Provider
		let provider = BasicProvider(
			dataSource: dataSource,
			viewSource: viewSource,
			sizeSource: sizeSource
		)
		
		let layout = WaterfallLayout(columns: 4, spacing: ReagentSelectionView.REAGANT_BUTTON_PADDING_HEIGHT)
		
		provider.layout = layout
		collectionView.provider = provider
		
		// Add items to stack
		mainStack.addArrangedSubview(self.testTubeView)
		mainStack.addArrangedSubview(collectionView)

		self.updateCollectionHeight()
				
		// Add main stack to view
		self.addSubview(mainStack)
		
		// Constrain main stack
		mainStack.snp.makeConstraints { constrain in
			constrain.leading.equalToSuperview()
			constrain.trailing.equalToSuperview()
			constrain.top.equalToSuperview()
			constrain.bottom.equalToSuperview()
		}
		
		// Update data on reagant selected changed
		_ = self.selectionWrapper.indexedReagents.observe { _ in
			self.collectionView.reloadData()
		}
	}
	
	private func updateCollectionHeight() {
		// Constrain collection view to exact height needed
		self.collectionView!.snp.makeConstraints { constrain in
			let buttonHeight = ReagentSelectionView.REAGANT_BUTTON_HEIGHT
			let buttonSpacing = ReagentSelectionView.REAGANT_BUTTON_PADDING_HEIGHT
			
			let numRows = CGFloat(ceil(Double(self.selectionWrapper.reagents.count) / 4.0))
			
			let height = buttonHeight * numRows
			let paddingAdd = buttonSpacing * (numRows - 1)

			constrain.height.equalTo(height + paddingAdd)
		}
	}
	
	// Introduce subscript numerals into regent names
	private func buildButtonDisplay(title: String, font: UIFont, color: UIColor) -> NSMutableAttributedString {
		let fontSub = font.withSize(15)
		
		// Create string with given font and color
		let attString: NSMutableAttributedString = NSMutableAttributedString(string: title, attributes: [
			.font: font,
			.foregroundColor: color
		])
		
		for i in 0..<title.count {
			// Determine string index
			let curIndex = title.index(title.startIndex, offsetBy: i)
			
			if title[curIndex].isNumber {
				attString.setAttributes([
					.font:fontSub,
					.baselineOffset: -5,
					.foregroundColor: color
				], range: NSRange(location: i, length:1))
			}
		}
		
		return attString
	}
	
}
