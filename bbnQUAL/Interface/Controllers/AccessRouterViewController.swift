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
class AccessRouterViewController: UIViewController {
	
    private var user: QualUser?
    private var userAccess: Int?
    
    private var childController: UIViewController?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Either discover user or redirect to child router
        if self.user == nil {
            self.discoverCurrentUser()
        } else {
            self.doPresentation()
        }
    }
    
    // Override dismiss to ensure that we dismiss any presented controllers first.
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        // Dismiss the student controller
        self.undoPresentation()
        
        super.dismiss(animated: flag, completion: completion)
    }
    
    private func discoverCurrentUser() {
        // Get current user info
        UserManager.shared.getUser().then(listener: self) {
            switch $0 {
            case .success(let user):
                // Save user and listen to access level updates
                self.user = user
                
                // Attempt to show children
                self.doPresentation()

                // Listen for user access changes
                self.listenToAccessChanges()
                
            case .failure(let error):
                print(error)
                // TODO: Determine what we should do here????
            }
        }
    }
    
    private func listenToAccessChanges() {
        if let user = self.user {
            user.handler.updated.then(listener: self) {
                switch $0 {
                case .success:
                    // If the user's access level changed, we dismiss children back to this controller
                    if user.access != self.userAccess {
                        self.undoPresentation()
                    }
                case .failure(let error):
                    print(error)
                    
                    self.dismiss(animated: false, completion: nil)
                }
            }
        }
    }
    
    private func doPresentation() {
        if let user = self.user {
            var controllerName: String
            
            // Switch based on the user's access level
            switch user.access {
            case 0:
                controllerName = "StudentRouter"
            default:
                controllerName = "TeacherRouter"
            }
            
            // Store current user access level
            self.userAccess = user.access
            
            if let controller = self.storyboard?.instantiateViewController(identifier: controllerName) {
                // Transfer user object to presented views
                var castedController = controller as! RouterUserSupplied
                castedController.user = user
                
                controller.modalPresentationStyle = .fullScreen
                
                self.childController = controller
                
                self.present(controller, animated: false, completion: nil)
            } else {
                print("Couldn't perform access routing")
            }
        }
    }
    
    private func undoPresentation() {
        if let controller = self.childController {
            controller.dismiss(animated: false, completion: nil)
        }
    }
	
}

protocol RouterUserSupplied {
    
    var user: QualUser! { get set }
    
}
