//
//  StudentGameFinishedViewController.swift
//  bbnQUAL
//
//  Created by Dylan Hanson on 12/27/19.
//  Copyright © 2019 Jovialis. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import Bond

class StudentGameFinishedViewController: UIViewController {
		
	var progression: ProgressionProgress!
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
		stack.spacing = 15

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
		subLabel.text = "Your group finished QUAL"

		mainLabel.font = UIFont(name: "PTSans-Bold", size: 60)
		subLabel.font = UIFont(name: "PTSans-Regular", size: 40)

		// Create tube view
		let tubeWrapper = UIView()
		stack.addArrangedSubview(tubeWrapper)
		
		let tubeLabel = TestTubeView()
		tubeWrapper.addSubview(tubeLabel)
		
		// Configure tube view
		tubeLabel.label = ":)"
		
		// Constrain tube view
		tubeLabel.snp.makeConstraints { constrain in
			constrain.leading.equalToSuperview()
			constrain.trailing.equalToSuperview()
			constrain.bottom.equalToSuperview()
			constrain.top.equalToSuperview().inset(75)
		}
		
		// Bottom stack
		let progressStack = UIStackView()
		self.view.addSubview(progressStack)
		
		// Configure bottom stack
		progressStack.axis = .horizontal
		progressStack.spacing = 30
		
		// Constrain stack
		progressStack.snp.makeConstraints { (constrain) in
			constrain.centerX.equalToSuperview()
			constrain.bottom.equalToSuperview().inset(40)
		}
		
		// Bottom progress labels
		let regularLabel = UILabel()
		progressStack.addArrangedSubview(regularLabel)
		
		let challengeLabel = UILabel()
		progressStack.addArrangedSubview(challengeLabel)
		
		// Configure bottom progress labels
		regularLabel.text = "\( self.progression.regular.completed ) Regular Sets Completed"
		challengeLabel.text = "\( self.progression.challenge.completed ) Challenge Sets Completed"
	
		regularLabel.font = UIFont(name: "PTSans-Regular", size: 20)
		challengeLabel.font = UIFont(name: "PTSans-Regular", size: 20)
		
		regularLabel.textColor = .secondaryLabel
		challengeLabel.textColor = .secondaryLabel
		
		// Confetti
		let confettiView = ConfettiView(frame: self.view.bounds)
		self.confettiView = confettiView
		self.view.addSubview(confettiView)

		// Configure confetti
		confettiView.type = .Diamond
		confettiView.startConfetti()
	}
	
	// Stop confetti
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		
		self.confettiView.stopConfetti()
	}
	
}
