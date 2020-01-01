//
//  ActionOpenGoogleAuthDialogue.swift
//  bbnQUAL
//
//  Created by Dylan Hanson on 12/31/19.
//  Copyright © 2019 Jovialis. All rights reserved.
//

import Foundation
import Signals
import Firebase
import AuthenticationServices
import Alamofire

class ActionOpenGoogleAuthDialogue: SpecificControllerAction<AuthController, Bool> {
	
	private var session: ASWebAuthenticationSession!
	
	override func execute() -> Signal<Bool> {
		// Grab signal object from super
		let callback = super.execute();
		
		let options = FirebaseApp.app()!.options
		let clientId = options.clientID!
		let state = generateStateToken(length: 24)
		
		// Find the redirect domain by reversing the client ID
		let redirectDomain = FirebaseApp.app()!.options.clientID!.split(separator: ".").reversed().joined(separator: ".")

		// Auth domain
		let url = URL(string:
			"https://accounts.google.com/o/oauth2/v2/auth?" +
			"state=\(state)&" +
			"response_type=code&" +
			"scope=profile+email+openid&" +
			"client_id=\(clientId)&" +
			"redirect_uri=\(redirectDomain):/gauth"
		)!
					
		// Open the actual session
		self.openSession(clientId: clientId, state: state, url: url, redirectDomain: redirectDomain, callback: callback)
		
		return callback
	}
	
	private func openSession(clientId: String, state: String, url: URL, redirectDomain: String, callback: Signal<Bool>) {
		// Instantiate authentication controller
		let controller = ASWebAuthenticationSession(url: url, callbackURLScheme: redirectDomain) { callbackUrl, error in
			// Digest URL
			if let callbackUrl = callbackUrl {
				let components = URLComponents(url: callbackUrl, resolvingAgainstBaseURL: false)
				
				let returnedState = components?.queryItems?.first(where: { $0.name == "state" })?.value
				let emailDomain = components?.queryItems?.first(where: { $0.name == "hd" })?.value
				
				// Only continue if the state is unchanged
				if returnedState != state {
					print("Invalid state returned")
					
					self.failedToOpenSession(callback: callback)
					return
				}
				
				// Lock login to BBNS only
//				if emailDomain?.lowercased() != "bbns.org" {
//					signal.fire(.failure(error: "Cannot sign in a non-BBN email."))
//				}
				
				guard let code = components?.queryItems?.first(where: { $0.name == "code" })?.value else {
					print("No resulting Google Auth code found")

					self.failedToOpenSession(callback: callback)
					return
				}

				// Token exchange headers
				let headers = [
					"Content-Type": "application/x-www-form-urlencoded"
				]
				
				// Token exchange data
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
								print(error)
								
								self.failedToOpenSession(callback: callback)
								return
							}
							
							// Extract variables from successful Google response
							let token = mapped["access_token"] as! String
							let idToken = mapped["id_token"] as! String
							let refreshToken = mapped["refresh_token"] as! String
							let expiration = mapped["expires_in"] as! Int
									
							// Save tokens
							self.controller.saveGoogleAuthToKeychain(idToken: idToken, accessToken: token, refreshToken: refreshToken, expiration: expiration)
							
							// Attempt Firebase auth
							self.controller.firebaseAuth(idToken: idToken, accessToken: token).then(listener: self) {
								switch $0 {
								case .success:
									// Nothing
									break
									
								case .failure(let error):
									print(error)
									
									self.failedToOpenSession(callback: callback)
								}
							}
						} else {
							print("Recieved unparsable data from Google.")
							self.failedToOpenSession(callback: callback)
						}
						
					case .failure(let error):
						print(error)
						self.failedToOpenSession(callback: callback)
					}
				}
			} else {
				print(error!)
				self.failedToOpenSession(callback: callback)
			}
		}
		
		controller.presentationContextProvider = self.controller
		controller.start()
		
		self.session = controller
	}
	
	// Return a state token for OAuth
	private func generateStateToken(length: Int) -> String {
		let charactersString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
		let charactersArray = Array(arrayLiteral: charactersString)

		var string = ""
		for _ in 0..<length {
			string += charactersArray[Int(arc4random()) % charactersArray.count]
		}

		return string
	}
	
	private func failedToOpenSession(callback: Signal<Bool>) {
		// Instantiate error controller
		let errorController = ErrorRetryController(title: "Google Auth Failed", alertTitle: "Done") {
			
			// Notify of failure
			callback.fire(false)
			
		}
		
		self.controller.present(errorController, animated: true, completion: nil)
	}
	
}
