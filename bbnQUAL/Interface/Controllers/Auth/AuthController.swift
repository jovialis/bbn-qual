//
//  AuthController.swift
//  bbnQUAL
//
//  Created by Dylan Hanson on 12/31/19.
//  Copyright © 2019 Jovialis. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import KeychainSwift
import Firebase
import Bond
import AuthenticationServices

class AuthController: UIViewController, ASWebAuthenticationPresentationContextProviding {
	
	private var loadingIndicator: UIActivityIndicatorView!
	private var loginButton: LoginButton!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Setup views
		self.setupViews();
		
		// If we have keychain credentials, attempt to login with them.
		if self.hasStoredCredentials() {
			self.attemptLoginWithStoredCredentials()
		} else {
			// Otherwise, open login dialogue
			self.showLoginOption()
		}
	}
	
	private func setupViews() {
		self.view.backgroundColor = .systemBackground

		// Create stack
		let stack = UIStackView()
		self.view.addSubview(stack)
		
		// Configure stack
		stack.spacing = 50
		stack.alignment = .center
		stack.axis = .vertical
		
		// Constrian stack
		stack.snp.makeConstraints { (constrain: ConstraintMaker) in
			constrain.center.equalToSuperview()
		}
		
		// QUAL label
		let label = UILabel()
		stack.addArrangedSubview(label)
		
		// Configure label
		label.text = "QUAL Login"
		label.font = UIFont(name: "PTSans-Bold", size: 60)
		
		// Loading indicator
		self.loadingIndicator = UIActivityIndicatorView(style: .large)
		stack.addArrangedSubview(self.loadingIndicator)
		
		// Start loading indicator
		self.loadingIndicator.startAnimating()
		
		// Button
		self.loginButton = LoginButton()
		stack.addArrangedSubview(self.loginButton)
		self.loginButton.layoutSubviews()
		
		// Hide
		self.loginButton.isHidden = true
		
		// On button click
		self.loginButton.reactive.tapGesture().observe { _ in
			self.openLoginDialogue()
		}
	}
	
	private func showLoginOption() {
		// Hide loading indicator
		self.loadingIndicator.isHidden = true
		
		// Show login button
		self.loginButton.isHidden = false
		self.loginButton.stopAnimating()
	}
	
	private func showLoading() {
		// Show loading indicator
		self.loadingIndicator.isHidden = false
		
		// Hide login button
		self.loginButton.isHidden = true
	}
	
	private func openLoginDialogue() {
		self.showLoading()
		
		// Open action
		ActionOpenGoogleAuthDialogue(controller: self).execute().then(listener: self) { (success) in
			
			// Success means do nothing. Failure means show button again
			if !success {
				self.showLoginOption()
			}
			
		}
	}
	
	private func hasStoredCredentials() -> Bool {
        // Load session from keychain
        let keychain = KeychainSwift()
        let idToken = keychain.get("id_token")
        let token = keychain.get("access_token")
        let refreshToken = keychain.get("refresh_token")
		
		return idToken != nil && token != nil && refreshToken != nil
	}
	
	func saveGoogleAuthToKeychain(idToken: String, accessToken: String, refreshToken: String, expiration: Int) {
		// Store tokens in keychain
		let keychain = KeychainSwift()
		keychain.set(idToken, forKey: "id_token")
		keychain.set(accessToken, forKey: "access_token")
		keychain.set(refreshToken, forKey: "refresh_token")
		keychain.set("\( (expiration + Int(Date().timeIntervalSince1970)) )", forKey: "expires_in")
	}
	
	private func attemptLoginWithStoredCredentials() {
		// Refresh our token
		ActionRefreshGoogleToken(controller: self).execute().then(listener: self) { (success) in
			if success {
				
				// Grab the new tokens from keychain
				let keychain = KeychainSwift()
				let idToken = keychain.get("id_token")!
				let token = keychain.get("access_token")!

				self.firebaseAuth(idToken: idToken, accessToken: token).then(listener: self) {
					switch $0 {
					case .success:
						break // Nothing else!
						
					case .failure(let error):
						print(error)
						
						// Open login dialogue
						self.showLoginOption()
					}
				}
				
			} else {
				
				// Failed to refresh token. Open login dialogue.
				self.showLoginOption()
				
			}
		}
	}
	
	func firebaseAuth(idToken: String, accessToken: String) -> CallbackSignal<Void> {
		let signal = CallbackSignal<Void>()

		// Create credentials and authenticate Firestore instance
		let credentials = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
		Auth.auth().signIn(with: credentials) { (result: AuthDataResult?, error: Error?) in
			if let result = result {
				print("Signed in user \(result.user.email!)")
				signal.fire(.success(object: ()))
			} else {
				signal.fire(.failure(error: error!))
			}
		}
		
		return signal
	}
	
	// Anchor for AS Authentication Session
	func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
		return self.view.window!
	}
	
}
