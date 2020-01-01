//
//  ActionRefreshGoogleToken.swift
//  bbnQUAL
//
//  Created by Dylan Hanson on 1/1/20.
//  Copyright © 2020 Jovialis. All rights reserved.
//

import Foundation
import Signals
import KeychainSwift
import Firebase
import Alamofire

class ActionRefreshGoogleToken: SpecificControllerAction<AuthController, Bool> {
	
	override func execute() -> Signal<Bool> {
		// Grab callback from super
		let callback = super.execute()
		
        // Load session from keychain
        let keychain = KeychainSwift()
        let refreshToken = keychain.get("refresh_token")!
		
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
					if let error = mapped["error"] as? String {
						print(error)
						
						// Failed to refresh
						callback.fire(false)
						return
					}
					
					// Extract data from response
					let idToken = mapped["id_token"] as! String
					let token = mapped["access_token"] as! String
					let expiration = mapped["expires_in"] as! Int
					
					// Store in keychain
					self.controller.saveGoogleAuthToKeychain(idToken: idToken, accessToken: token, refreshToken: refreshToken, expiration: expiration)
					
					// Succeeded in refresh
					callback.fire(true)
				} else {
					print("Failed to process data while parsing google refresh token response")
					
					// Failed to refresh
					callback.fire(false)
				}
				
			case .failure(let error):
				print(error)
				
				// Failed to refresh
				callback.fire(false)
			}
		}

		
		return callback
	}
	
}
