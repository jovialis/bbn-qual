//
//  ActionButton.swift
//  bbnQUAL
//
//  Created by Dylan Hanson on 1/7/20.
//  Copyright © 2020 Jovialis. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class ActionButton: UIButton {
	
	private var setup: Bool = false
	
	private(set) var loading: Bool = false
	private var loadingIndicator: UIActivityIndicatorView!
			
	private var textColor: UIColor!
	
	convenience init(title: String, background: UIColor, text: UIColor, border: Bool = false, size: CGFloat = 22.0) {
		self.init(frame: CGRect.zero)
		self.setup(title: title, background: background, text: text, border: border, size: size)
	}
	
	private func setup(title: String = "Title", background: UIColor = .label, text: UIColor = .systemBackground, border: Bool = false, size: CGFloat = 22.0) {
		if self.setup {
			return
		}
		
		// Store title color for loading
		self.textColor = text
		
		self.setup = true

		// Title
		self.setTitle(title, for: .normal)
		self.titleLabel?.font = UIFont(name: "PTSans-Regular", size: size)

		// Colors
		self.setTitleColor(text, for: .normal)
		self.backgroundColor = background

		// If border or not
		if border {
			self.layer.borderColor = text.cgColor
			self.layer.borderWidth = 0.5
		}
		
		// Insets
		self.contentEdgeInsets = UIEdgeInsets(top: 10, left: 35, bottom: 10, right: 35)
		
		self.setupLoadingIndicator(color: text)
		
		self.hideLoading()
	}
	
	private func setupLoadingIndicator(color: UIColor) {
		// Loading indicator
		self.loadingIndicator = UIActivityIndicatorView()
		self.addSubview(self.loadingIndicator)
		
		// Configure loading
		self.loadingIndicator.style = .medium
		self.loadingIndicator.hidesWhenStopped = true
		self.loadingIndicator.color = color
	}

	override func updateConstraints() {
		super.updateConstraints()
		
		self.loadingIndicator.snp.makeConstraints { (constrain: ConstraintMaker) in
			constrain.center.equalToSuperview()
		}
	}
	
	func hideLoading() {
		self.loading = false
		
		self.setTitleColor(self.textColor, for: .normal)
		self.loadingIndicator.isHidden = true
	}
	
	func showLoading() {
		self.loading = true
		
		self.setTitleColor(self.backgroundColor, for: .normal)
		self.loadingIndicator.isHidden = false
		self.loadingIndicator.startAnimating()
	}
	
}
