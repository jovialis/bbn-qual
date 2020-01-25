//
//  TeacherCourseTabSettings.swift
//  bbnQUAL
//
//  Created by Dylan Hanson on 1/24/20.
//  Copyright © 2020 Jovialis. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class TeacherCourseSettingsStoryboardController: UIViewController {
	
	var course: Course!
	
	@IBOutlet weak var assignDemoGroupLabel: UILabel!
	@IBOutlet weak var assignDemoGroupSwitch: UISwitch!
	
	@IBOutlet weak var numNormalGroupsLabel: UILabel!
	@IBOutlet weak var numNormalGroupsStepper: UIStepper!
	
	@IBOutlet weak var numChallengeGroupsLabel: UILabel!
	@IBOutlet weak var numChallengeGroupsStepper: UIStepper!

	@IBOutlet weak var numAttemptsBeforeCheckinLabel: UILabel!
	@IBOutlet weak var numAttemptsBeforeCheckinStepper: UIStepper!
	
	@IBOutlet weak var numAttemptsAfterCheckinLabel: UILabel!
	@IBOutlet weak var numAttemptsAfterCheckinStepper: UIStepper!
	
	@IBOutlet weak var goLiveButton: UIButton!
	
	// Timer to save settings after 3 seconds of inactivity
	private var saveTimer: Timer?
	private let TIMER_DELAY = 3.0
	
	override func viewDidLoad() {
		super.viewDidLoad()
				
		// Default values
		self.setupControlValues()
		self.displayControlValues()
		
		// Bind changes in controls to save
		self.bindChangesToSave()
	}
	
	private func setupControlValues() {
		let settings = self.course.settings
		
		// Set default label values
		self.assignDemoGroupSwitch.isOn = settings.beginnerGroup
		self.numNormalGroupsStepper.value = Double(settings.numRegularGroups)
		self.numChallengeGroupsStepper.value = Double(settings.numChallengeGroups)
		self.numAttemptsBeforeCheckinStepper.value = Double(settings.attemptsBeforeFreeze)
		self.numAttemptsAfterCheckinStepper.value = Double(settings.attemptsAfterFreeze)
	}
	
	private func displayControlValues() {
		// Visual displays
		self.assignDemoGroupLabel.text = "\( self.assignDemoGroupSwitch.isOn ? "" : "Do Not " )Assign Practice Group"
		self.numNormalGroupsLabel.text = "\( Int(self.numNormalGroupsStepper.value) ) Regular Group\( self.numNormalGroupsStepper.value == 1 ? "" : "s" )"
		self.numChallengeGroupsLabel.text = "\( Int(self.numChallengeGroupsStepper.value) ) Challenge Group\( self.numChallengeGroupsStepper.value == 1 ? "" : "s" )"
		self.numAttemptsBeforeCheckinLabel.text = "\( Int(self.numAttemptsBeforeCheckinStepper.value) ) Attempt\( self.numAttemptsBeforeCheckinStepper.value == 1 ? "" : "s" ) Before Check-In"
		self.numAttemptsAfterCheckinLabel.text = "\( Int(self.numAttemptsAfterCheckinStepper.value) ) Attempt\( self.numAttemptsAfterCheckinStepper.value == 1 ? "" : "s" ) After Check-In"
	}
	
	private func bindChangesToSave() {
		// Bindings
		self.assignDemoGroupSwitch.onValueChanged.subscribe(with: self) {
			self.setNeedsSave()
			
			// Redisplay
			self.displayControlValues()
		}
		
		self.numNormalGroupsStepper.onValueChanged.subscribe(with: self) {
			self.setNeedsSave()
			
			// Redisplay
			self.displayControlValues()
		}
		
		self.numChallengeGroupsStepper.onValueChanged.subscribe(with: self) {
			self.setNeedsSave()
			
			// Redisplay
			self.displayControlValues()
		}
		
		self.numAttemptsBeforeCheckinStepper.onValueChanged.subscribe(with: self) {
			self.setNeedsSave()
			
			// Redisplay
			self.displayControlValues()
		}
		
		self.numAttemptsAfterCheckinStepper.onValueChanged.subscribe(with: self) {
			self.setNeedsSave()
			
			// Redisplay
			self.displayControlValues()
		}
	}

	private func setNeedsSave() {
		// Cancel previous timer
		if let timer = self.saveTimer {
			timer.invalidate()
		}
		
		self.saveTimer = Timer.scheduledTimer(withTimeInterval: self.TIMER_DELAY, repeats: false, block: { (_) in
			// Perform save after a few seconds
			self.performSave()
		})
	}
	
	private func performSave() {
		print("Attempting to save Course settings.")
		
		// Course
		self.course.ref.updateData([
			"settings": [
				
				"assignBeginnerGroup": self.assignDemoGroupSwitch.isOn,
				"attemptsAfterFreeze": Int(self.numAttemptsAfterCheckinStepper.value),
				"attemptsBeforeFreeze": Int(self.numAttemptsBeforeCheckinStepper.value),
				"numChallengeGroups": Int(self.numChallengeGroupsStepper.value),
				"numRegularGroups": Int(self.numNormalGroupsStepper.value)
				
			]
		]) { (error: Error?) in
			
			// Handle error
			if let error = error {
				print(error)
				
				// Present retry controller
				self.present(ErrorRetryController(message: "Could not save Course config.", alertTitle: "Retry") {
					// Try to save again
					self.performSave()
					
				}, animated: false, completion: nil)
			}
		}
	}
	
}
