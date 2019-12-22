//
//  TeacherRouterViewController.swift
//  bbnQUAL
//
//  Created by Dylan Hanson on 12/5/19.
//  Copyright © 2019 Jovialis. All rights reserved.
//

import Foundation
import UIKit

class TeacherRouterViewController: UIViewController, RouterUserSupplied {
    
    // Supplied by the instantiator
    var user: QualUser!
	
	var teacherController: UIViewController?
    
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		self.doPresentation()
    }
	
    private func doPresentation() {
        let storyboard = UIStoryboard(name: "Teacher", bundle: nil)
        
        if let controller = storyboard.instantiateInitialViewController() as? TeacherWrapperViewController {
			controller.teacher = self.user
			controller.modalPresentationStyle = .fullScreen
			controller.modalTransitionStyle = .coverVertical
			
			// Present
			self.present(controller, animated: true, completion: nil)
        }
    }
    
    private func undoPresentation() {
        if let controller = self.teacherController {
            controller.dismiss(animated: true, completion: nil)
            
            self.teacherController = nil
        }
    }
    
}
