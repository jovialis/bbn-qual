//
//  QError.swift
//  bbnQUAL
//
//  Created by Dylan Hanson on 12/3/19.
//  Copyright © 2019 Jovialis. All rights reserved.
//

import Foundation

enum QError {
    
    case insufficientData
    
}

extension QError: Error {
    
    var localizedDescription: String {
        switch self {
        case .insufficientData:
            return "Insufficient data provided for object to function."
        }
    }
    
}
