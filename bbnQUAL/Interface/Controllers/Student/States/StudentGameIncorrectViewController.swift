//
//  StudentGameIncorrectViewController.swift
//  bbnQUAL
//
//  Created by Dylan Hanson on 12/28/19.
//  Copyright © 2019 Jovialis. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import Bond

class StudentGameIncorrectViewController: UIViewController {
	
	var onContinueClicked: () -> Void = {}
	var attemptsLeft: Int!
		
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
		
		let attemptsLabel = UILabel()
		stack.addArrangedSubview(attemptsLabel)

		// Configure labels
		mainLabel.text = "Oops"
		subLabel.text = "That's not quite right..."
		attemptsLabel.text = "Teacher check-in after \( self.attemptsLeft! ) more attempts"

		mainLabel.font = UIFont(name: "PTSans-Bold", size: 40)
		subLabel.font = UIFont(name: "PTSans-Regular", size: 30)
		attemptsLabel.font = UIFont(name: "PTSans-Regular", size: 20)
		
		attemptsLabel.textColor = .tertiaryLabel

		// Create continue button
		let button = UIButton()
		self.view.addSubview(button)

		// Configure button
		button.backgroundColor = .label
		button.setTitleColor(.systemBackground, for: .normal)
		button.setTitle("Try Again", for: .normal)
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
	
}
