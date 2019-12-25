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

	// Subviews
	private var svgView: MacawView!
	
	// Configuration vars
	var label: String? {
		didSet {
			self.updateView()
		}
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		// Setup view if not setup
		if !self.setup {
			self.setupView()
		}
	}
	
	private func setupView() {
		self.setup = true
		
		self.backgroundColor = .clear
		
		var resourceName: String
		if traitCollection.userInterfaceStyle == .light {
			resourceName = "TestTube-Light"
		} else {
			resourceName = "TestTube-Dark"
		}
				
		// SVG View
		let node = try! SVGParser.parse(resource: resourceName)
		self.svgView = MacawView(node: node, frame: .zero)
		self.addSubview(svgView!)

		// Configure SVG View
		self.svgView!.backgroundColor = .clear
		self.svgView!.contentMode = .scaleAspectFit
		
		// Constrain view to left, right, and center of superview
		self.svgView!.snp.makeConstraints { constrain in
			constrain.center.equalToSuperview()
			
			constrain.top.equalToSuperview()
			constrain.bottom.equalToSuperview()
			
			constrain.leading.equalToSuperview()
			constrain.trailing.equalToSuperview()
		}
		
		// Update the view
		self.updateView()
	}
	
	private func updateView() {
		// Setup view if not setup
		if !self.setup {
			self.setupView()
		}
		
		// Update label
		let labelGroup = svgView.node.nodeBy(tag: "label") as! Group
		let label = (labelGroup.contents.first as? Text)!
		
		label.text = self.label ?? ""
	}
	
//	private func colorSVG() {
//		// Float pointers
//		var red: CGFloat = 0
//		var green: CGFloat = 0
//		var blue: CGFloat = 0
//		var alpha: CGFloat = 0
//
//		// Outline the shape with the current Label color
//		if UIColor.label.resolvedColor(with: .current).getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
////			let color = Color.rgba(r: 255, g: 255, b: 255, a: 1.0)
//			let color = Color.rgba(r: Int(red * 255), g: Int(green * 255), b: Int(blue * 255), a: 1.0)
//			let newStroke = Stroke(fill: color, width: 3.0, cap: .square, join: .round, miterLimit: 0.0, dashes: [], offset: 0.0)
//
//			// Fill shapes
//			(self.svgView.node.nodeBy(tag: "outline")?.nodeBy(tag: "outline") as! Shape).stroke = newStroke
//			(self.svgView.node.nodeBy(tag: "stripe")?.nodeBy(tag: "stripe")  as! Shape).stroke = newStroke
//
//			let label = self.svgView.node.nodeBy(tag: "stripe")?.nodeBy(tag: "stripe")  as! Shape
//			label.fill = color
//		}
//	}
	
}
