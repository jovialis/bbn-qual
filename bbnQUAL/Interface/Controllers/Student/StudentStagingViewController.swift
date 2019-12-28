//
//  StudentStagingViewController.swift
//  bbnQUAL
//
//  Created by Dylan Hanson on 12/27/19.
//  Copyright © 2019 Jovialis. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import Signals
import FirebaseFunctions
import SwiftyJSON

class StudentStagingViewController: UIViewController {
	
	/*
	Controller to manage the states inbetween selection, loading, etc.
	*/
	
	// TODO: Handle dismiss
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Create loading view
		let loadingView = UIActivityIndicatorView()
		loadingView.style = .large
		loadingView.startAnimating()
		
		// Add loading to self
		self.view.addSubview(loadingView)
		
		loadingView.snp.makeConstraints {
			$0.center.equalToSuperview()
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		self.doRouting()
	}
	
	private func doRouting() {
		self.fetchReagentGroup().then(listener: self) {
			switch $0 {
			case .success(let progression):
				switch progression.status {
				case .finished:
					self.presentFinishedController(progress: progression.progress)
				case .frozen(let icebergCode):
					self.presentFrozenController(icebergCode: icebergCode)
				case let .active(prefix, difficulty, attempts, reagents):
					self.presentStudentController(prefix: prefix, difficulty: difficulty, attempts: attempts, reagents: reagents, progress: progression.progress)
				}
				
			case .failure(let error):
				print(error)
			}
		}
	}
	
	func presentStudentController(prefix: String, difficulty: ProgressionDifficulty, attempts: Int, reagents: [Reagent], progress: ProgressionProgress) {
		if let controller = self.storyboard?.instantiateViewController(identifier: "Game") as? StudentGameViewController {
			
			// Set necessary variables
			controller.prefix = prefix
			controller.difficulty = difficulty
			controller.reagents = reagents
			controller.progress = progress
			
			// Present fullscreen
			controller.modalPresentationStyle = .fullScreen
			self.present(controller, animated: false, completion: nil)
			
		}
	}
	
	func presentFrozenController(icebergCode: String) {
		let controller = StudentGameFrozenViewController()
		
		controller.icebergCode = icebergCode
		
		// Present fullscreen
		controller.modalPresentationStyle = .fullScreen
		self.present(controller, animated: false, completion: nil)
	}
	
	func presentFinishedController(progress: ProgressionProgress) {
		let controller = StudentFinishedViewController()
		
		controller.progression = progress
		controller.modalTransitionStyle = .crossDissolve
		controller.modalPresentationStyle = .fullScreen
		
		self.present(controller, animated: true, completion: nil)
	}
	
	// Fetches the current reagent group
	func fetchReagentGroup() -> CallbackSignal<Progression> {
		// Signal
		let signal = CallbackSignal<Progression>()
		
		// Get the current reagent group
		let function = Functions.functions().httpsCallable("getReagentGroup")
		function.call { (result: HTTPSCallableResult?, error: Error?) in
			if let result = result {
				
				// Extract data
				do {
					let json = JSON(result.data)
					
					// Pull out progression from JSON
					guard let progression = Progression(json: json) else {
						print(json)
						throw "Invalid arguments prevented instantiation of Progression"
					}
					
					signal.fire(.success(object: progression))
				} catch {
					signal.fire(.failure(error: error))
				}
				
			} else {
				signal.fire(.failure(error: error!))
			}
		}
		
		return signal
	}

}

