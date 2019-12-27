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
	
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var tubeWrapperView: UIView!
	
	private var collectionView: CollectionView!
	
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
					case .incorrect:
						print("Incorrect answer")
						break
					case .finished:
						self.dismiss(animated: false, completion: nil)
						break
					case .correct:
						self.presentCorrectAnswerController()
						break
					}
					
				case .failure(let error):
					print(error)
					
					// TODO: Handle this
				}
				
			}
			
		}
	}
	
	private func presentCorrectAnswerController() {
		let controller = StudentGameCorrectViewController()
		
		// Handle the continue button
		controller.onContinueClicked = {
			self.dismiss(animated: false, completion: nil)
		}
		
		controller.modalPresentationStyle = .pageSheet
		self.present(controller, animated: true, completion: nil)
	}
	
}
