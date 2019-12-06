//
//  LoginViewController.swift
//  bbnQUAL
//
//  Created by Dylan Hanson on 11/25/19.
//  Copyright © 2019 Jovialis. All rights reserved.
//

import Foundation
import UIKit
import AuthenticationServices
import Firebase
import Alamofire
import KeychainSwift

class LoginViewController: UIViewController, ASWebAuthenticationPresentationContextProviding {
	
	private var session: ASWebAuthenticationSession!
	
	@IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
	@IBOutlet weak var loginButton: UIButton!
	
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.loadingIndicator.isHidden = false
        self.loginButton.isHidden = true
        
        // Load session from keychain
        let keychain = KeychainSwift()
        
        let idToken = keychain.get("id_token")
        let token = keychain.get("access_token")
        let refreshToken = keychain.get("refresh_token")
        
        // Couldn't load session from keychain
        if idToken == nil || token == nil || refreshToken == nil {
            self.loadingIndicator.stopAnimating()
            self.loginButton.isHidden = false
            return
        }
        
        // Refresh all tokens
        refreshGoogleAuthToken(refreshToken: refreshToken!)
    }
	
	@IBAction func onGoogleLogin(_ sender: Any) {
		self.openAuthDialogue()
	}
	
	func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
		return self.view.window!
	}
	
	func openAuthDialogue() {
		let options = FirebaseApp.app()!.options
		let clientId = options.clientID!
		let state = generateStateToken(length: 24)
		
		// Find the redirect domain by reversing the client ID
		let redirectDomain = FirebaseApp.app()!.options.clientID!.split(separator: ".").reversed().joined(separator: ".")
	//	let redirectDomain = FirebaseApp.app()!.options.clientID!
				
		let url = URL(string:
			"https://accounts.google.com/o/oauth2/v2/auth?" +
			"state=\(state)&" +
			"response_type=code&" +
			"scope=profile+email+openid&" +
			"client_id=\(clientId)&" +
			"redirect_uri=\(redirectDomain):/gauth"
		)!
						
		let controller = ASWebAuthenticationSession(url: url, callbackURLScheme: redirectDomain) { callbackUrl, error in
			// Digest URL
			if let callbackUrl = callbackUrl {
				let components = URLComponents(url: callbackUrl, resolvingAgainstBaseURL: false)
				
				let returnedState = components?.queryItems?.first(where: { $0.name == "state" })?.value
				let emailDomain = components?.queryItems?.first(where: { $0.name == "hd" })?.value
				
				// Only continue if the state is unchanged
				if returnedState != state {
					print("Invalid state")
					return
				}
				
				// Lock login to BBNS only
				if emailDomain?.lowercased() != "bbns.org" {
					print("Invalid email domain")
//					return
				}
				
				guard let code = components?.queryItems?.first(where: { $0.name == "code" })?.value else {
					print("No resulting code found!")
					return
				}

				let headers = [
					"Content-Type": "application/x-www-form-urlencoded"
				]
				
				let parameters: [String: String] = [
					"code": code,
					"client_id": clientId,
					"redirect_uri": "\(redirectDomain):/gauth",
					"grant_type": "authorization_code"
				]
				
				// Request token
				AF.request("https://oauth2.googleapis.com/token", method: .post, parameters: parameters, encoding: URLEncoding.httpBody, headers: HTTPHeaders(headers)).responseJSON() { response in
					
					switch response.result {
					case .success(let data):
						if let mapped = data as? [String: Any] {
							// Google threw an error
							if let error = mapped["error"] {
								print("An error occurred: \(error)")
								print(mapped["error_description"]!)
								return
							}
							
							// Extract variables from successful Google response
							let token = mapped["access_token"] as! String
							let idToken = mapped["id_token"] as! String
							
							let refreshToken = mapped["refresh_token"] as! String
							let expiration = mapped["expires_in"] as! Int
										
							self.performFirebaseAuth(idToken: idToken, accessToken: token)
							self.saveGoogleAuthToKeychain(idToken: idToken, accessToken: token, refreshToken: refreshToken, expiration: expiration + Int(Date().timeIntervalSince1970))
						} else {
							print(data)
						}
					case .failure(let error):
						print(error)
					}
				}
			} else {
				print(error!)
			}
		}
		
		controller.presentationContextProvider = self
		controller.start()
		
		self.session = controller
	}
	
	private func refreshGoogleAuthToken(refreshToken: String) {
		let headers = [
			"Content-Type": "application/x-www-form-urlencoded"
		]
		
		let parameters: [String: String] = [
			"refresh_token": refreshToken,
			"client_id": FirebaseApp.app()!.options.clientID!,
			"grant_type": "refresh_token"
		]
		
		// AF google token refresh call
		AF.request("https://oauth2.googleapis.com/token", method: .post, parameters: parameters, encoding: URLEncoding.httpBody, headers: HTTPHeaders(headers)).responseJSON() { response in
			switch response.result {
			case .success(let data):
				if let mapped = data as? [String: Any] {
					// Google threw an error
					if let error = mapped["error"] {
						print("An error occurred: \(error)")
						print(mapped["error_description"]!)
						return
					}
					
					let idToken = mapped["id_token"] as! String
					let token = mapped["access_token"] as! String
					let expiration = mapped["expires_in"] as! Int
					
					self.performFirebaseAuth(idToken: idToken, accessToken: token)
					self.saveGoogleAuthToKeychain(idToken: idToken, accessToken: token, refreshToken: refreshToken, expiration: expiration + Int(Date().timeIntervalSince1970))
				} else {
					print("Failed to process data while parsing google refresh token response")
				}
				
			case .failure(let error):
				print(error)
			}
		}
	}
	
	private func generateStateToken(length: Int) -> String {
		let charactersString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
		let charactersArray = Array(arrayLiteral: charactersString)

		var string = ""
		for _ in 0..<length {
			string += charactersArray[Int(arc4random()) % charactersArray.count]
		}

		return string
	}
	
	private func performFirebaseAuth(idToken: String, accessToken: String) {
		// Create credentials and authenticate Firestore instance
		let credentials = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
		Auth.auth().signIn(with: credentials) { (result: AuthDataResult?, error: Error?) in
			if error != nil {
				print("Could not authenticate Firestore")
				print(error!)
				return
			}
			
			let result = result!
			print("Signed in user \(result.user.email!)")
			
			// Load current user to user manager
            UserManager.shared.setCurrentUserId(userId: result.user.uid)
						
			self.didLogin()
		}
	}
	
	private func saveGoogleAuthToKeychain(idToken: String, accessToken: String, refreshToken: String, expiration: Int) {
		// Store tokens in keychain
		let keychain = KeychainSwift()
		keychain.set(idToken, forKey: "id_token")
		keychain.set(accessToken, forKey: "access_token")
		keychain.set(refreshToken, forKey: "refresh_token")
		keychain.set("\(expiration)", forKey: "expires_in")
	}
	
	func didLogin() {
		print("Successfully logged in.")
				
		// Push to hub
		let storyboard = UIStoryboard(name: "Router", bundle: nil)
        let controller = storyboard.instantiateInitialViewController()!
        
        controller.modalPresentationStyle = .fullScreen
        
        self.present(controller, animated: false, completion: nil)
	}
	
}
