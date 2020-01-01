//
//  Team.swift
//  bbnQUAL
//
//  Created by Dylan Hanson on 1/1/20.
//  Copyright © 2020 Jovialis. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Team {
	
	let members: [TeamMember]
	
	init?(json: JSON) {
		guard let members = json["members"].array else {
			return nil
		}
		
		self.members = members.compactMap { TeamMember(json: $0) }
	}
	
}

struct TeamMember {
	
	let name: String
	let email: String
	
	init?(json: JSON) {
		guard let name = json["name"].string else {
			return nil
		}
		
		guard let email = json["email"].string else {
			return nil
		}
		
		self.name = name
		self.email = email
	}
	
}
