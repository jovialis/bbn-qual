//
//  Callback.swift
//  Alumn
//
//  Created by Dylan Hanson on 7/18/19.
//  Copyright © 2019 Jovialis. All rights reserved.
//

import Foundation
import Signals

// Represents a succeed/fail result
enum Callback<T> {
	case success(object: T)
	case failure(error: Error)
}

typealias CallbackSignal<T> = Signal<Callback<T>>

// Prettier and faster way to listen to signals
extension CallbackSignal {
    
    convenience init() {
        self.init(retainLastData: true)
    }
    
    func then(listener: AnyObject, callback: @escaping (T) -> Void) {
        self.subscribePast(with: listener, callback: callback)
    }
    
}
