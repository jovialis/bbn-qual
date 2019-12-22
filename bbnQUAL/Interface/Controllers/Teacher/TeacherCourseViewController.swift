//
//  TeacherCourseViewController.swift
//  bbnQUAL
//
//  Created by Dylan Hanson on 12/21/19.
//  Copyright © 2019 Jovialis. All rights reserved.
//

import Foundation
import UIKit
import CollectionKit
import Bond
import ReactiveKit

class TeacherCourseViewController: UIViewController {
	
	var course: Course!
	
	// Storyboard bindings
	// Teacher labels
	@IBOutlet weak var settingsNumTeachersLabel: UILabel!
	@IBOutlet weak var settingsTeacherNamesLabel: UILabel!
	
	// Demo group switch
	@IBOutlet weak var settingsDemoGroupSwitch: UISwitch!
	
	// Normal groups
	@IBOutlet weak var settingsNumNormalGroupsLabel: UILabel!
	@IBOutlet weak var settingsNumNormalGroupsStepper: UIStepper!
	
	// Challenge Groups
	@IBOutlet weak var settingsNumChallengeGroupsLabel: UILabel!
	@IBOutlet weak var settingsNumChallengeGroupsStepper: UIStepper!
	
	// User group collection
	@IBOutlet weak var groupsCollectionView: CollectionView!
	
	// Reagent group collection
	@IBOutlet weak var reagentGroupsCollectionView: CollectionView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Non-clear background to cover previous controller
		self.view.backgroundColor = .systemBackground
		
		// Bindings
		
	}
	
	@IBAction func settingsEditTeachersButton(_ sender: UIButton) {
		// TODO: Modally present edit teachers page
	}
	
	@IBAction func settingsGoLiveButton(_ sender: UIButton) {
		// TODO: Go live!
	}
	
}
