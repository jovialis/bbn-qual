//
//  StudentRouterViewController.swift
//  bbnQUAL
//
//  Created by Dylan Hanson on 12/4/19.
//  Copyright © 2019 Jovialis. All rights reserved.
//

import Foundation
import UIKit

// Obtains a student session and listens to it. If it's valid, we present hte student controller, if it becomes invalid
// then we dismiss the student controller.
class StudentRouterViewController: UIViewController, RouterUserSupplied {    
        
    // Supplied by the instantiator
    var user: QualUser!
    var session: QualSession?
    
    var studentController: UIViewController?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Attempt to find a session for the user
        self.obtainSessionForUser(user: self.user)
    }
    
    @IBAction func userPressedCheckForSession(_ sender: Any) {
        // Attempt to find a session for the user
        self.obtainSessionForUser(user: self.user)
    }
    
    // Override dismiss to ensure that we dismiss any presented controllers first.
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        // Dismiss the student controller
        self.undoPresentation()
        
        super.dismiss(animated: flag, completion: completion)
    }
    
    private func obtainSessionForUser(user: QualUser) {
        SessionManager.shared.getSession(user: user).then(listener: self) {
            switch $0 {
            case .success(let session):
                self.session = session
                self.listenToSessionExpiration()
                
            case .failure(let error):
                print(error)
                
                self.session = nil
            }
            
            // Update the view based
            self.doRouting()
        }
    }
    
    private func listenToSessionExpiration() {
        if let session = self.session {
            session.handler.updated.then(listener: self) {
                switch $0 {
                case .success:
                    // If the session expired, pop the student controller
                    if session.expired {
                        self.undoPresentation()
                        self.session = nil
                    }
                    
                    break
                                        
                // Connection error means we pop the student controller and get a new session
                case .failure(let error):
                    print(error)
                    
                    self.session = nil
                    self.undoPresentation()
                }
            }
        }
    }
    
    private func doRouting() {
        if self.session == nil {
            // Attempt to dismiss the student controller if it's been presented. There is no longer a session.
            self.undoPresentation()
        } else {
            // Present the student controller
            self.doPresentation()
        }
    }
    
    private func doPresentation() {
        let storyboard = UIStoryboard(name: "Student", bundle: nil)
        
        if let controller = storyboard.instantiateInitialViewController() {
            self.studentController = controller
            
            controller.modalPresentationStyle = .fullScreen
            self.present(controller, animated: false, completion: nil)
        }
        
        
        // TODO: Present the student controller
    }
    
    private func undoPresentation() {
        if let controller = self.studentController {
            controller.dismiss(animated: false, completion: nil)
            
            self.studentController = nil
        }
    }
    
}
