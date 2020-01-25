//
//  String+Error.swift
//  bbnQUAL
//
//  Created by Dylan Hanson on 12/27/19.
//  Copyright © 2019 Jovialis. All rights reserved.
//

import Foundation

extension String: LocalizedError {
	
    public var errorDescription: String? { return self }
	
}
