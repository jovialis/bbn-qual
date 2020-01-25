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
		
	// Subviews
	private var svgView: MacawView!
	
	// Configuration vars
	var label: String? {
		didSet {
			self.setNeedsLayout()
		}
	}
	
	convenience init(label: String) {
		self.init(frame: .zero)
		self.label = label
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
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		// Update label
		let labelGroup = svgView.node.nodeBy(tag: "label") as! Group
		let label = (labelGroup.contents.first as? Text)!
		
		label.text = self.label ?? ""
	}
	
}
