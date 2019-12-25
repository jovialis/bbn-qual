//
//  StudentViewController.swift
//  bbnQUAL
//
//  Created by Dylan Hanson on 12/23/19.
//  Copyright © 2019 Jovialis. All rights reserved.
//

import Foundation
import UIKit
import CollectionKit
import SnapKit
import Bond

class Reagant: Hashable {
	
	let name: String
	var selected: Observable<Bool>
	
	init(_ name: String, selected: Bool = false) {
		self.name = name
		self.selected = Observable<Bool>(selected)
	}
	
	static func ==(lhs: Reagant, rhs: Reagant) -> Bool {
		return lhs.name == rhs.name
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(self.name)
	}
	
}

class StudentViewController: UIViewController {
	
	@IBOutlet weak var titleLabel: UILabel!
	
	@IBOutlet weak var tubeWrapperView: UIView!
	
	private var collectionView: CollectionView!
	
	var reagants: [Reagant] = [
		Reagant("BaCl"),
		Reagant("NaCl"),
		Reagant("HCl"),
		Reagant("BaNO3"),
		Reagant("NaOH2"),
		Reagant("CrH"),
		Reagant("Phenol Red"),
		Reagant("H2O")
	]
	
	var selectedItems: [Int: Reagant] = [:]
		
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let collectionView = CollectionView()
		self.collectionView = collectionView
		self.tubeWrapperView.addSubview(collectionView)
		
		// Bounce
		collectionView.alwaysBounceVertical = true
		
		collectionView.snp.makeConstraints { constrain in
			constrain.leading.equalToSuperview()
			constrain.trailing.equalToSuperview()
			constrain.top.equalToSuperview()
			constrain.bottom.equalToSuperview()
		}
		
		let dataSource = ArrayDataSource(data: self.reagants)

		let viewSource = ClosureViewSource { (view: ReagentSelectionView, data: Reagant, index: Int) in
			view.reagants = self.reagants
			view.tubeName = "100\( (index + 1) )"
		}
		
		let sizeSource = { (index: Int, data: Reagant, collectionSize: CGSize) -> CGSize in
			return CGSize(width: 600, height: 200)
		}
				
		let provider = BasicProvider(
			dataSource: dataSource,
			viewSource: viewSource,
			sizeSource: sizeSource
		)
		
		let layout = FlowLayout(spacing: 100, justifyContent: .center, alignItems: .center, alignContent: .center)
		
		provider.layout = layout
		collectionView.provider = provider
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
	}
	
	@IBAction func checkAnswersSelected(_ sender: Any) {

	}
	
}
