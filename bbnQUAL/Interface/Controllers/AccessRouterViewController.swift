//
//  AccessRouterViewController.swift
//  bbnQUAL
//
//  Created by Dylan Hanson on 11/28/19.
//  Copyright © 2019 Jovialis. All rights reserved.
//

import Foundation
import UIKit

// Redirects the view based on the user's access level.
// Level 0 will be sent to the student controller, while
// Level 1-2 will be sent to the teacher controller
class HubViewController: UIViewController {
	
    // Anytime this view appears
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Load the user's current access level
        self.obtainUserAccessLevel()
    }
    
    private func obtainUserAccessLevel() {
        // Get current user info
        UserManager.shared.getUser().then(listener: self) {
            switch $0 {
            case .success(let user):
                self.performRouting(user: user)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func performRouting(user: QualUser) {
        var storyboardName: String
        
        switch user.access {
        case 0:
            storyboardName = "StudentRouter"
        default:
            storyboardName = "TeacherRouter"
        }
        
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        if let controller = storyboard.instantiateInitialViewController() {
            self.present(controller, animated: false, completion: nil)
        } else {
            print("Couldn't perform access routing")
        }
    }
	
}
