//
//  Team.swift
//  bbnQUAL
//
//  Created by Dylan Hanson on 1/1/20.
//  Copyright © 2020 Jovialis. All rights reserved.
//

import Foundation
import SwiftyJSON
import Firebase

protocol TeamSkeleton {
	
	associatedtype MemberType: TeamMemberSkeleton
	var members: [MemberType] { get }
	
}

// Simple course struct for maintaining information security.
// Primarily used by StudentSession fetching.
struct TeamOverview: TeamSkeleton {
	
	let members: [TeamMemberOverview]
	
	init?(json: JSON) {
		guard let members = json["members"].array else {
			return nil
		}
		
		self.members = members.compactMap { TeamMemberOverview(json: $0) }
	}
	
}

struct Team: TeamSkeleton {
	
	let ref: DocumentReference
	let members: [TeamMember]
	
	init?(reference: DocumentReference, json: JSON) {
		guard let members = json["members"].array else {
			return nil
		}
		
		self.ref = reference
		self.members = members.compactMap { TeamMember(json: $0) }
	}
	
}

protocol TeamMemberSkeleton {
	
	var name: String { get }
	var email: String { get }
	
}

struct TeamMemberOverview: TeamMemberSkeleton {
	
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

struct TeamMember: TeamMemberSkeleton {
	
	let ref: DocumentReference
	let name: String
	let email: String
	
	init?(json: JSON) {
		guard let name = json["name"].string else {
			return nil
		}
		
		guard let email = json["email"].string else {
			return nil
		}
		
		guard let ref = json["ref"].rawValue as? DocumentReference else {
			return nil
		}
		
		self.ref = ref
		self.name = name
		self.email = email
	}
	
}
