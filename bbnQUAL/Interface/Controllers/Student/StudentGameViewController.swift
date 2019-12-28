//
//  StudentViewController.swift
//  bbnQUAL
//
//  Created by Dylan Hanson on 12/23/19.
//  Copyright © 2019 Jovialis. All rights reserved.
//

import Foundation
import UIKit
import CollectionKit
import SnapKit
import Bond
import FirebaseFunctions

class StudentGameViewController: UIViewController {
	
	@IBOutlet weak var tubeWrapperView: UIView!
	private var collectionView: CollectionView!
	
	@IBOutlet weak var currentGroupLabel: UILabel!
	@IBOutlet weak var testTubeNamesStack: UIStackView!
	@IBOutlet weak var compoundNamesStack: UIStackView!
	
	// Variables configured/updated by presenting controller
	var prefix: String!
	var progress: ProgressionProgress!
	var difficulty: ProgressionDifficulty!
	var reagents: [Reagent] = [] {
		didSet {
			// Update the wrapper
			self.reagentsSelectionWrapper = ReagentSelectionWrapper(reagents: self.reagents)
			
			// Reload collection view
			if let collectionView = self.collectionView {
				collectionView.reloadData()
				
				// Reload sidebar if views are loaded
				self.updateSidebar()
			}
		}
	}
	
	private lazy var reagentsSelectionWrapper = ReagentSelectionWrapper(reagents: self.reagents)
				
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let collectionView = CollectionView()
		self.collectionView = collectionView
		self.tubeWrapperView.addSubview(collectionView)
		
		// Bounce
		collectionView.alwaysBounceVertical = true
		
		collectionView.snp.makeConstraints { constrain in
			constrain.leading.equalToSuperview()
			constrain.trailing.equalToSuperview()
			constrain.top.equalToSuperview()
			constrain.bottom.equalToSuperview()
		}
		
		let dataSource = ArrayDataSource(data: self.reagents)

		let viewSource = ClosureViewSource { (view: ReagentSelectionView, data: Reagent, index: Int) in
			view.index = index
			view.tubeName = "\( self.prefix! )\( (index + 1) )"

			view.selectionWrapper = self.reagentsSelectionWrapper
		}
		
		let sizeSource = { (index: Int, data: Reagent, collectionSize: CGSize) -> CGSize in
			return CGSize(width: 600, height: 200)
		}
				
		let provider = BasicProvider(
			dataSource: dataSource,
			viewSource: viewSource,
			sizeSource: sizeSource
		)
		
		let layout = FlowLayout(spacing: 100, justifyContent: .center, alignItems: .center, alignContent: .center)
		
		provider.layout = layout
		collectionView.provider = provider
		
		// Update sidebar
		self.updateSidebar()
	}
	
	private func updateSidebar() {
		// Update sidebar title
		if let difficulty = self.difficulty, let progress = self.progress {
			if difficulty != .practice {
				let difficultyProgress = progress.forDifficulty(difficulty)
				let difficultyName = difficulty.displayName
				
				self.currentGroupLabel.text = "\( difficultyName ) Set \( (difficultyProgress.completed + 1) )/\( difficultyProgress.required )"
			} else {
				self.currentGroupLabel.text = "Practice Set"
			}
		}
		
		// Tube labels
		if let prefix = self.prefix {
			var tubeNames: [String] = []
			
			for i in 0..<self.reagents.count {
				tubeNames.append("\( prefix )\( (i + 1) )")
			}
			
			// Update items in stack
			self.addTestTubeNamesToSidebar(names: tubeNames)
		}
		
		// Reagent names
		self.addCompoundNamesToSidebar(names: self.reagents)
	}
	
	private func addTestTubeNamesToSidebar(names: [String]) {
		// Clear current items
		self.testTubeNamesStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
		
		for name in names {
			let label = UILabel()
			self.testTubeNamesStack.addArrangedSubview(label)

			label.text = "- \(name)"
			label.font = UIFont(name: "PTSans-Regular", size: 22.0)
		}
	}
	
	private func addCompoundNamesToSidebar(names: [Reagent]) {
		// Clear current items
		self.compoundNamesStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
		
		for name in names {
			let label = UILabel()
			self.compoundNamesStack.addArrangedSubview(label)

			label.text = "- \(name.name)"
			label.font = UIFont(name: "PTSans-Regular", size: 22.0)
		}
	}
	
	@IBAction func checkAnswersSelected(_ sender: Any) {
		if self.reagentsSelectionWrapper.validateDataStructuring() {
			
			// Check answers
			self.reagentsSelectionWrapper.checkAnswers().then(listener: self) {
				
				// Handle success vs. failure
				switch $0 {
				case .success(let result):
					
					switch result {
					case .formattingError:
						print("Incorrect data format!? That should not be possible. Why are we here??")
						break
						
					case .incorrect(let attempts):
						self.presentIncorrectAnswerController(attemptsLeft: attempts)
						break
						
					case .finished:
						// Dismiss to staging so it can present the big congratulations controller
						self.dismiss(animated: false, completion: nil)
						break
						
					case .frozen(let code):
						self.presentFrozenController(iceberg: code)
						break
						
					case .correct(let attempts):
						self.presentCorrectAnswerController(attempts: attempts)
						break
					}
					
				case .failure(let error):
					print(error)
					
					// TODO: Handle this
				}
				
			}
			
		}
	}
	
	private func presentIncorrectAnswerController(attemptsLeft: Int) {
		let controller = StudentGameIncorrectViewController()
		
		controller.attemptsLeft = attemptsLeft
		
		// Handle the continue button
		controller.onContinueClicked = {
			// Nothing
		}

		controller.modalPresentationStyle = .pageSheet
		controller.modalTransitionStyle = .crossDissolve

		self.present(controller, animated: true, completion: nil)
	}
	
	private func presentFrozenController(iceberg: String) {
		let controller = StudentGameFrozenViewController()
		
		controller.icebergCode = iceberg
		
		controller.modalPresentationStyle = .pageSheet
		controller.modalTransitionStyle = .crossDissolve
		
		self.present(controller, animated: true, completion: nil)
		
		// TODO: Dismiss when signal
	}
	
	private func presentCorrectAnswerController(attempts: Int) {
		let controller = StudentGameCorrectViewController()
		
		// Handle the continue button
		controller.onContinueClicked = {
			self.dismiss(animated: false, completion: nil)
		}
		
		controller.modalPresentationStyle = .pageSheet
		controller.modalTransitionStyle = .crossDissolve

		self.present(controller, animated: true, completion: nil)
	}
	
}
