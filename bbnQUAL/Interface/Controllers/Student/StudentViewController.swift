//
//  StudentViewController.swift
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

class StudentViewController: UIViewController {
	
	/*
	Controller to manage the states inbetween selection, loading, etc.
	*/
	
	var isTopController: Bool { return self.navigationController?.topViewController == self }
	
	private var course: CourseOverview!
	private var team: TeamOverview!
	
	convenience init(course: CourseOverview, team: TeamOverview) {
		self.init()
		
		self.course = course
		self.team = team
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.view.backgroundColor = .systemBackground
		
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
		
		// Route upon appearance
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
					self.presentStudentController(
						prefix: prefix,
						difficulty: difficulty,
						attempts: attempts,
						reagents: reagents,
						progress: progression.progress
					)
				}
				
			case .failure(let error):
				print(error)
			}
		}
	}
	
	func presentStudentController(prefix: String, difficulty: ProgressionDifficulty, attempts: Int, reagents: [Reagent], progress: ProgressionProgress) {
		// Pop to self
		self.popToSelf()
		
		// Instantiate Game controller from storyboard
		let storyboard = UIStoryboard(name: "Game", bundle: nil)
		if let controller = storyboard.instantiateInitialViewController() as? StudentGameViewController {
			
			// Set necessary variables
			controller.course = self.course
			controller.team = self.team
			
			controller.prefix = prefix
			controller.difficulty = difficulty
			controller.reagents = reagents
			controller.progress = progress
			
			// Present fullscreen
			self.navigationController?.pushViewController(controller, animated: false)
		}
	}
	
	func presentFrozenController(icebergCode: String) {
		// Pop to self
		self.popToSelf()
		
		let controller = StudentGameFrozenViewController()
		
		controller.icebergCode = icebergCode
		
		// Present fullscreen
		self.navigationController?.pushViewController(controller, animated: false)
	}
	
	func presentFinishedController(progress: ProgressionProgress) {
		// Pop to self
		self.popToSelf()
		
		let controller = StudentFinishedViewController()
		
		controller.progression = progress
		
		self.navigationController?.pushViewController(controller, animated: false)
	}
	
	// Clear the navigation stack back to self.
	private func popToSelf() {
		if !self.isTopController {
			self.navigationController?.popToViewController(self, animated: false)
		}
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
					let json = JSONObject(result.data)
					
					// Pull out progression from JSON
					guard let progression = Progression(json: json) else {
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

