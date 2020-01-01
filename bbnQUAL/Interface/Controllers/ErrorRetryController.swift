//
//  ErrorRetryController.swift
//  bbnQUAL
//
//  Created by Dylan Hanson on 1/1/20.
//  Copyright © 2020 Jovialis. All rights reserved.
//

import Foundation
import UIKit

class ErrorRetryController: UIAlertController {
	
	private var onRetry: () -> Void = {}
	private var alertTitle: String = "Retry"
	
	convenience init(title: String = "An Error Occurred", message: String? = nil, alertTitle: String = "Retry", onRetry: @escaping () -> Void) {
		self.init(title: title, message: message, preferredStyle: .alert)
		self.onRetry = onRetry
		self.alertTitle = alertTitle
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Configure retry action
		let action = UIAlertAction(title: self.alertTitle, style: .default) { (action: UIAlertAction) in
			self.onRetry()
		}
		
		// Add action
		self.addAction(action)
	}
	
}
