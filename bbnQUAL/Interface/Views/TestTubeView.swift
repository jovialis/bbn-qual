//
//  TestTubeView.swift
//  bbnQUAL
//
//  Created by Dylan Hanson on 11/27/19.
//  Copyright © 2019 Jovialis. All rights reserved.
//

import Foundation
import UIKit
import Macaw
import SnapKit

class TestTubeView: UIView {
		
	private var setup: Bool = false

	// Timer to update the view color
	private var timer: Timer!

	// Subviews
	private var svgView: MacawView!
	private var textLabel: UILabel!
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		// Setup view if not setup
		if !self.setup {
			self.setupView()
			self.setup = true
		}
	}
	
	private func setupView() {
		self.backgroundColor = .clear
		
		// SVG View
		let node = try! SVGParser.parse(resource: "TestTube")
		self.svgView = MacawView(node: node, frame: .zero)
		self.addSubview(svgView)

		// Configure SVG View
		self.svgView.backgroundColor = .clear
		self.svgView.contentMode = .scaleAspectFit
		
		// Color SVG View
		self.colorSVG()
		
		// Constrain view to left, right, and center of superview
		self.svgView.snp.makeConstraints { constrain in
			constrain.center.equalToSuperview()
			
			constrain.top.equalToSuperview()
			constrain.bottom.equalToSuperview()
			
			constrain.leading.equalToSuperview()
			constrain.trailing.equalToSuperview()
		}
		
		// Label stack
		let labelStack = UIStackView()
		let spacerView = UIView()
		let label = UILabel()

		self.addSubview(labelStack)
		labelStack.addArrangedSubview(spacerView)
		labelStack.addArrangedSubview(label)

		labelStack.axis = .vertical
		labelStack.alignment = .fill
		labelStack.distribution = .equalSpacing
		labelStack.spacing = 0.0

		spacerView.backgroundColor = .clear
		spacerView.snp.makeConstraints {
			$0.height.equalTo(self.svgView.snp.height).dividedBy(3.27)
		}

		label.font = UIFont(name: "PTSans-Bold", size: 22.0)
		label.textColor = .systemBackground
		label.text = "1001"
		label.textAlignment = .center

		labelStack.snp.makeConstraints {
			$0.top.equalTo(self.svgView.snp.top)
			$0.centerX.equalToSuperview()
		}

		print(self.subviews)
	}
	
	private func colorSVG() {
		// Float pointers
		var red: CGFloat = 0
		var green: CGFloat = 0
		var blue: CGFloat = 0
		var alpha: CGFloat = 0
		
		// Outline the shape with the current Label color
		if UIColor.label.resolvedColor(with: .current).getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
//			let color = Color.rgba(r: 255, g: 255, b: 255, a: 1.0)
			let color = Color.rgba(r: Int(red * 255), g: Int(green * 255), b: Int(blue * 255), a: 1.0)
			let newStroke = Stroke(fill: color, width: 3.0, cap: .square, join: .round, miterLimit: 0.0, dashes: [], offset: 0.0)
			
			// Fill shapes
			(self.svgView.node.nodeBy(tag: "top") as! Shape).stroke = newStroke
			(self.svgView.node.nodeBy(tag: "bottom") as! Shape).stroke = newStroke
			
			let label = self.svgView.node.nodeBy(tag: "label") as! Shape
			label.fill = color
		}

		// Fill the tube with a hot pink theme color
		let shape = self.svgView.node.nodeBy(tag: "bottom") as! Shape
		shape.fill = Color.rgb(r: 251, g: 59, b: 129)
	}
	
}
