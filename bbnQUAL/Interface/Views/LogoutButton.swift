//
//  LogoutButton.swift
//  bbnQUAL
//
//  Created by Dylan Hanson on 1/2/20.
//  Copyright © 2020 Jovialis. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import KeychainSwift
import SnapKit

class LogoutButton: UIButton {
	
	private var setup = false
	
	private var loadingIndicator: UIActivityIndicatorView!
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		if !self.setup {
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
		self.setTitle("Log Out", for: .normal)
		self.backgroundColor = .label
		self.setTitleColor(.systemBackground, for: .normal)
		self.titleLabel?.font = UIFont(name: "PTSans-Regular", size: 22)
		
		self.contentEdgeInsets = UIEdgeInsets(top: 10, left: 35, bottom: 10, right: 35)
		
		// Observe click
		self.onTouchUpInside.subscribe(with: self) {
			// Show loading indicator when clicked
			self.loadingIndicator.isHidden = false
			self.loadingIndicator.startAnimating()

			self.logout()
		}
		
		// Hide loading by default
		self.loadingIndicator.isHidden = true
	}
	
	private func logout() {
		// Wipe keychain then trigger auth logout
		do {
			self.wipeKeychain()
			try Auth.auth().signOut()
		} catch {
			print(error)
		}
	}
	
	private func wipeKeychain() {
		// Wipe tokens from keychain
		let keychain = KeychainSwift()
		keychain.delete("id_token")
		keychain.delete("access_token")
		keychain.delete("refresh_token")
	}
	
}
