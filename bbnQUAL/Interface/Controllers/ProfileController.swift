//
//  ProfileController.swift
//  bbnQUAL
//
//  Created by Dylan Hanson on 1/2/20.
//  Copyright © 2020 Jovialis. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import SnapKit
import Alamofire
import KeychainSwift

class ProfileController: UIViewController {
	
//	var access: Int!
//	var team: TeamOverview?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Setup views
		self.setupViews()
	}
	
	private func setupViews() {
		self.view.backgroundColor = .systemBackground
		
		// Stack view
		let stack = UIStackView()
		self.view.addSubview(stack)
		
		// Constrain stack
		stack.snp.makeConstraints { (constrain: ConstraintMaker) in
			constrain.leading.equalToSuperview().offset(30)
			constrain.trailing.equalToSuperview().inset(30)
			constrain.top.equalToSuperview().offset(40)
			constrain.bottom.equalToSuperview()
		}
		
		// Configure stack
		stack.alignment = .fill
		stack.axis = .vertical
		stack.distribution = .fill
		stack.spacing = 10
		
		// Header horizontal stack
		let horizontalHeader = UIStackView()
		stack.addArrangedSubview(horizontalHeader)
		
		// Configure header stack
		horizontalHeader.axis = .horizontal
		horizontalHeader.spacing = 10
		horizontalHeader.alignment = .center
		
		// Constrain header
		horizontalHeader.snp.makeConstraints { (constrain: ConstraintMaker) in
			constrain.width.equalToSuperview()
			constrain.height.equalTo(70)
		}
		
		// User icon
		let imageView = UIImageView()
		horizontalHeader.addArrangedSubview(imageView)
		
		// Constrain icon
		imageView.snp.makeConstraints { (constrain: ConstraintMaker) in
			constrain.height.equalTo(60)
			constrain.width.equalTo(60)
		}
		
		// Configure user icon
		imageView.backgroundColor = .secondarySystemBackground
		imageView.layer.cornerRadius = 30
		imageView.clipsToBounds = true
		imageView.contentMode = .scaleAspectFit
		
		// Add loading indicator to image
		let loadingIcon = UIActivityIndicatorView()
		imageView.addSubview(loadingIcon)
		
		// Configure loading icon
		loadingIcon.style = .medium
		loadingIcon.startAnimating()
		loadingIcon.hidesWhenStopped = true
		
		// Constrain loading icon
		loadingIcon.snp.makeConstraints { (constrain: ConstraintMaker) in
			constrain.center.equalToSuperview()
		}
		
		// Fetch user icon
		self.getUserIcon(url: Auth.auth().currentUser?.photoURL).then(listener: self) {
			switch $0 {
			case .success(let image):
				loadingIcon.stopAnimating()
				imageView.image = image
				
			case .failure(let error):
				print(error)
			}
		}
		
		// Name stack
		let nameStack = UIStackView()
		horizontalHeader.addArrangedSubview(nameStack)
		
		// Configure name stack
		nameStack.axis = .vertical
		nameStack.spacing = 5
		nameStack.alignment = .leading
		
		// User name label
		let userLabel = UILabel()
		nameStack.addArrangedSubview(userLabel)
		
		// Configure user name label
		userLabel.text = Auth.auth().currentUser?.displayName
		userLabel.font = UIFont(name: "PTSans-Regular", size: 26)
		
		// User email label
		let emailLabel = UILabel()
		nameStack.addArrangedSubview(emailLabel)
		
		// Configure email label
		emailLabel.text = Auth.auth().currentUser?.email
		emailLabel.font = UIFont(name: "PTSans-Regular", size: 20)
		emailLabel.textColor = .secondaryLabel
		
		// Logout button
		let logoutButton = LogoutButton()
		horizontalHeader.addArrangedSubview(logoutButton)

		// Dismiss self on logout
		logoutButton.onTouchDown.subscribe(with: self) {
			self.dismiss(animated: true, completion: nil)
		}
		
		let scroll = UIScrollView()
		stack.addArrangedSubview(scroll)
	}
	
	private func getUserIcon(url: URL?) -> CallbackSignal<UIImage> {
		let callback = CallbackSignal<UIImage>()
		
		guard let url = url else {
			callback.fire(.failure(error: "No icon URL available for user."))
			return callback
		}
		
		// Call Alamofire
		AF.request(url).responseData { (response: AFDataResponse<Data>) in
			if let data = response.data {
				// Attempt to convert data to image
				if let image = UIImage(data: data) {
					// Resolve with image
					callback.fire(.success(object: image))
				} else {
					callback.fire(.failure(error: "Could not instantiate image with given data"))
				}
			} else if let error = response.error {
				// AF error
				callback.fire(.failure(error: error))
			} else {
				// Unknown error
				callback.fire(.failure(error: "Could not load icon"))
			}
		}
		
		return callback
	}
	
}
