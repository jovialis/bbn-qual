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

class TestTubeView: SVGView {
	
	private var timer: Timer!
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		self.fileName = "TestTube"
		self.backgroundColor = .clear
						
		var red: CGFloat = 0
		var green: CGFloat = 0
		var blue: CGFloat = 0
		var alpha: CGFloat = 0
		
		if UIColor.label.resolvedColor(with: .current).getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
			let color = Color.rgba(r: Int(red * 255), g: Int(green * 255), b: Int(blue * 255), a: Double(alpha))
			let newStroke = Stroke(fill: color, width: 3.0, cap: .square, join: .round, miterLimit: 0.0, dashes: [], offset: 0.0)
			
			(self.node.nodeBy(tag: "top") as! Shape).stroke = newStroke
			(self.node.nodeBy(tag: "bottom") as! Shape).stroke = newStroke
			
			let label = self.node.nodeBy(tag: "label") as! Shape
			label.stroke = newStroke
			label.fill = color
		}
		
		self.timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
			self.getRandomColor()
		}
	}
	
	
	
	func getRandomColor() {
		let red   = (arc4random() % 256)
		let green = (arc4random() % 256)
		let blue  = (arc4random() % 256)

		let shape = self.node.nodeBy(tag: "contents") as! Shape
		
		UIView.animate(withDuration: 0.5, animations: {
			shape.fill = Color.rgb(r: Int(red), g: Int(green), b: Int(blue))
		}, completion:nil)
	}
	
}
