//
//  ActionCourseNameExists.swift
//  bbnQUAL
//
//  Created by Dylan Hanson on 1/19/20.
//  Copyright © 2020 Jovialis. All rights reserved.
//

import Foundation
import Firebase
import Signals

class ActionCourseNameExists: Action<Callback<Bool>> {
	
	private let name: String
	
	init(name: String) {
		self.name = name
		super.init()
	}
	
	override func execute() -> CallbackSignal<Bool> {
		// Grab signal
		let callback = super.execute()
		
		// Look for a course with this name
		Firestore.firestore().collection("courses").whereField("name", isEqualTo: self.name).limit(to: 1).getDocuments { (snapshot: QuerySnapshot?, error: Error?) in
			
			if let snapshot = snapshot {
				
				if snapshot.documents.isEmpty {
					
					// Does not exist—return false
					callback.fire(.success(object: false))
					
				} else {
					
					// Exists, return true
					callback.fire(.success(object: true))
					
				}
				
			} else {
				
				// Pass error
				callback.fire(.failure(error: error!))
				
			}
			
		}
		
		return callback
	}
	
}
