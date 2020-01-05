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

class Action<Result> {
	
	@discardableResult
	func execute() -> Signal<Result> {
		let signal = Signal<Result>()
		return signal
	}
	
}

class SpecificControllerAction<Controller: UIViewController, Result>: Action<Result> {
	
	let controller: Controller
	
	init(controller: Controller) {
		self.controller = controller
	}
	
}

class ControllerAction<Result>: SpecificControllerAction<UIViewController, Result> {
	
}
