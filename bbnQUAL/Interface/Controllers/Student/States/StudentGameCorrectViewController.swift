//
//  StudentGameCorrectViewController.swift
//  bbnQUAL
//
//  Created by Dylan Hanson on 12/27/19.
//  Copyright © 2019 Jovialis. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import Bond

class StudentGameCorrectViewController: UIViewController {
	
	var onContinueClicked: () -> Void = {}
	
	private var confettiView: ConfettiView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Background
		self.view.backgroundColor = .systemBackground

		// Layout subviews
		// Create stack view for labels
		let stack = UIStackView()
		self.view.addSubview(stack)

		// Configure stack
		stack.alignment = .center
		stack.axis = .vertical
		stack.spacing = 10

		// Constrain stack
		stack.snp.makeConstraints { constrain in
			constrain.center.equalToSuperview()
		}

		// Create labels
		let mainLabel = UILabel()
		stack.addArrangedSubview(mainLabel)

		let subLabel = UILabel()
		stack.addArrangedSubview(subLabel)

		// Configure labels
		mainLabel.text = "Congratulations!"
		subLabel.text = "You answered correctly"

		mainLabel.font = UIFont(name: "PTSans-Bold", size: 40)
		subLabel.font = UIFont(name: "PTSans-Regular", size: 30)

		// Confetti
		let confettiView = ConfettiView(frame: self.view.bounds)
		self.confettiView = confettiView
		self.view.addSubview(confettiView)

		// Configure confetti
		confettiView.startConfetti()

		// Create continue button
		let button = UIButton()
		self.view.addSubview(button)

		// Configure button
		button.backgroundColor = .label
		button.setTitleColor(.systemBackground, for: .normal)
		button.setTitle("Next Reagent Set", for: .normal)
		button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 35, bottom: 10, right: 35)
		button.titleLabel?.font = UIFont(name: "PTSans-Regular", size: 24)

		// Constrain button
		button.snp.makeConstraints { constrain in
			constrain.centerX.equalToSuperview()
			constrain.bottom.equalToSuperview().inset(30)
		}

		// Action
		_ = button.reactive.tapGesture().observe { _ in
			self.dismiss(animated: true, completion: nil)
			self.onContinueClicked()
		}

	}
	
	// Stop confetti
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		
		self.confettiView.stopConfetti()
	}
	
}
