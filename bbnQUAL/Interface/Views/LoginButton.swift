//
//  LoginButton.swift
//  bbnQUAL
//
//  Created by Dylan Hanson on 1/2/20.
//  Copyright © 2020 Jovialis. All rights reserved.
//

import Foundation
import Firebase
import KeychainSwift
import SnapKit

class LoginButton: UIButton {
	
	private var setup = false
	
	private var loadingIndicator: UIActivityIndicatorView!
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		if !self.setup {
			self.setup = true
			self.setupView()
		}
	}
	
	private func setupView() {
		// Loading indicator
		self.loadingIndicator = UIActivityIndicatorView()
		self.addSubview(self.loadingIndicator)
		
		// Configure loading
		self.loadingIndicator.style = .medium
		self.loadingIndicator.hidesWhenStopped = true
		self.loadingIndicator.tintColor = .systemBackground
		
		self.loadingIndicator.snp.makeConstraints { (constrain: ConstraintMaker) in
			constrain.center.equalToSuperview()
		}
		
		// Configure self
		self.backgroundColor = .label
		self.setTitleColor(.systemBackground, for: .normal)
		self.titleLabel?.font = UIFont(name: "PTSans-Regular", size: 22)
		
		self.contentEdgeInsets = UIEdgeInsets(top: 10, left: 35, bottom: 10, right: 35)
		
		// Observe click
		self.onTouchUpInside.subscribe(with: self) {
			// Show loading indicator when clicked
			self.loadingIndicator.isHidden = false
			self.loadingIndicator.startAnimating()
			
			self.setTitle("", for: .normal)
		}
		
		// Hide loading by default
		self.stopAnimating()
	}
	
	func stopAnimating() {
		self.setTitle("Login With BB&N Email", for: .normal)
		self.loadingIndicator.stopAnimating()
	}
	
}
