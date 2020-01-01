//
//  ControllerAction.swift
//  bbnQUAL
//
//  Created by Dylan Hanson on 1/1/20.
//  Copyright © 2020 Jovialis. All rights reserved.
//

import Foundation
import UIKit
import Signals

class SpecificControllerAction<Controller: UIViewController, Result> {
	
	let controller: Controller
	
	init(controller: Controller) {
		self.controller = controller
	}
	
	@discardableResult
	func execute() -> Signal<Result> {
		let signal = Signal<Result>()
		return signal
	}
	
}

class ControllerAction<Result>: SpecificControllerAction<UIViewController, Result> {
	
}
