//
//  ConfettiView.swift
//  bbnQUAL
//
//  Created by Dylan Hanson on 12/27/19.
//  Copyright © 2019 Jovialis. All rights reserved.
//

// CREDIT: https://github.com/sudeepag/SAConfettiView

import Foundation
import UIKit
import QuartzCore

public class ConfettiView: UIView {

    public enum ConfettiType {
        case Confetti
        case Triangle
        case Star
        case Diamond
        case Image(UIImage)
    }

    var emitter: CAEmitterLayer!
    public var colors: [UIColor]!
    public var intensity: Float!
    public var type: ConfettiType!
    private var active :Bool!

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    func setup() {
        colors = [UIColor(red:0.95, green:0.40, blue:0.27, alpha:1.0),
            UIColor(red:1.00, green:0.78, blue:0.36, alpha:1.0),
            UIColor(red:0.48, green:0.78, blue:0.64, alpha:1.0),
            UIColor(red:0.30, green:0.76, blue:0.85, alpha:1.0),
            UIColor(red:0.58, green:0.39, blue:0.55, alpha:1.0)]
        intensity = 0.5
        type = .Confetti
        active = false
    }

    public func startConfetti() {
        emitter = CAEmitterLayer()

        emitter.emitterPosition = CGPoint(x: frame.size.width, y: 0)
		emitter.emitterShape = CAEmitterLayerEmitterShape.line
        emitter.emitterSize = CGSize(width: frame.size.width * 2, height: 1)

        var cells = [CAEmitterCell]()
        for color in colors {
			cells.append(confettiWithColor(color: color))
        }

        emitter.emitterCells = cells
        layer.addSublayer(emitter)
        active = true
    }

    public func stopConfetti() {
        emitter?.birthRate = 0
        active = false
    }

    func confettiImage() -> UIImage? {

		let imagePath = Bundle.main.path(forResource: "diamond", ofType: "png")
		let url = URL(fileURLWithPath: imagePath!)
		
		do {
			let data = try Data(contentsOf: url)
			return UIImage(data: data)
		} catch {
			return nil
		}
    }

    func confettiWithColor(color: UIColor) -> CAEmitterCell {
        let confetti = CAEmitterCell()
        confetti.birthRate = 6.0 * intensity
        confetti.lifetime = 14.0 * intensity
        confetti.lifetimeRange = 0
		confetti.color = color.cgColor
        confetti.velocity = CGFloat(350.0 * intensity)
        confetti.velocityRange = CGFloat(80.0 * intensity)
		confetti.emissionLongitude = CGFloat(Double.pi)
		confetti.emissionRange = CGFloat(Double.pi / 4)
        confetti.spin = CGFloat(3.5 * intensity)
        confetti.spinRange = CGFloat(4.0 * intensity)
        confetti.scaleRange = CGFloat(intensity)
        confetti.scaleSpeed = CGFloat(-0.1 * intensity)
		confetti.contents = confettiImage()!.cgImage
        return confetti
    }

    public func isActive() -> Bool {
    		return self.active
    }
}
