//
//  TeacherCourseMembersController.swift
//  bbnQUAL
//
//  Created by Dylan Hanson on 1/3/20.
//  Copyright © 2020 Jovialis. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import SnapKit
import Bond

class TeacherCourseTeamsController: UIViewController {
	
	private let TEAM_NAMES = ["Alpha", "Beta", "Gamma", "Delta", "Epsilon", "Zeta", "Eta", "Theta", "Iota", "Kappa", "Lambda", "Mu", "Nu", "Xi", "Omicron", "Pi", "Rho", "Sigma", "Tau", "Upsilon", "Phi", "Chi", "Psi", "Omega"]
	
	private var course: Course!
	private var teams: [SetupTeam] = []

	private var loading: UIActivityIndicatorView!
	private var teamsStack: UIStackView!
	
	private var timer: Timer?
		
	convenience init(course: Course) {
		self.init()
		self.course = course
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Setup views
		self.setupLoading()
		self.setupStack()
		
		self.loading.startAnimating()
		
		// Initial fetch teams
		self.fetchSetupTeams()
	}
	
	private func setupLoading() {
		self.loading = UIActivityIndicatorView()
		self.loading.style = .large
		self.loading.hidesWhenStopped = true
		
		self.view.addSubview(self.loading)
		
		self.loading.snp.makeConstraints { (constrain: ConstraintMaker) in
			constrain.centerX.equalToSuperview()
		} // /4
	}
	
	private func setupStack() {
		let masterStack = UIStackView()
		self.view.addSubview(masterStack)
		
		masterStack.axis = .vertical
		masterStack.spacing = 80
		masterStack.alignment = .fill
		masterStack.distribution = .fill
		
		// Constrain
		masterStack.snp.makeConstraints { $0.leading.trailing.top.equalToSuperview() }
		
		// Label
		let label = UILabel()
		label.text = "Setup Teams"
		
		masterStack.addArrangedSubview(label)
	
		// Teams stack
		self.teamsStack = UIStackView()
		self.teamsStack.axis = .vertical
		self.teamsStack.spacing = 20
		
		masterStack.addArrangedSubview(self.teamsStack)
		
		// Add button
		let addButton = UIButton()
		addButton.setTitle("Add Team", for: .normal)
		
		masterStack.addArrangedSubview(addButton)
		
		// On add clicked
		addButton.onTouchUpInside.subscribe(with: self) {
			self.teams.append(SetupTeam(ref: self.course.ref.collection("setupTeams").document(), name: self.generateTeamName()))
			self.updateTeamsDisplay()
		}
	}
	
	private func fetchSetupTeams() {
		// Reference collection
		let teamsRef = course.ref.collection("setupTeams")
		teamsRef.getDocuments { (snapshot: QuerySnapshot?, error: Error?) in
			
			if let snapshot = snapshot {
				
				// Parse documents
				let documents = snapshot.documents
				
				// Conver to setup teams
				let setupTeams = documents.compactMap { team in
					return SetupTeam(ref: team.reference, json: JSONObject(team.data()))
				}
				self.teams = setupTeams
				
				// Cancel loading and display temas
				self.loading.stopAnimating()
				self.updateTeamsDisplay()
				
			} else {
				print(error!)
			}
			
		}
	}
	
	func removeTeam(team: SetupTeam) {
		self.teams.first(where: { $0.ref.documentID == team.ref.documentID })!.deleted = true
		self.attemptSave()
		self.updateTeamsDisplay()
	}
	
	func removeEmailFromTeams(email: String) {
		self.teams.forEach { team in
			if team.contains(email: email) {
				team.remove(email: email)
			}
		}
	}
	
	private func generateTeamName() -> String {
		let usedTeamNames = self.teams.map { $0.name }
		var validTeamNames = self.TEAM_NAMES.map { "Team \( $0 )" }
		
		// Intersect so we have a list of possible team names
		validTeamNames.removeAll { usedTeamNames.contains($0) }
		
		return validTeamNames.first!
	}
	
	private func updateTeamsDisplay() {
		// Remove previous teams
		self.teamsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
		
		// Add a setup view for each team
		self.teams.forEach { team in
			if !team.deleted {
				self.teamsStack.addArrangedSubview(TeamSetupView(team: team, controller: self))
			}
		}
	}
	
	func attemptSave() {
		// Invalidate previous timer
		if let timer = self.timer {
			timer.invalidate()
		}
		
		// Schedule
		self.timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
			self.doSave()
		}
	}
	
	private func doSave() {
		print("Attempting to batch save teams.")
		
		let batch = Firestore.firestore().batch()
		
		// Save
		self.teams.forEach { team in
			
			let data: [String: Any] = [
				"name": team.name,
				"members": team.emails
			]
			
			// Deleted? we delete the doc
			if team.deleted {
				if !team.needToCreateDoc {
					batch.deleteDocument(team.ref)
				}
			} else if team.needToCreateDoc {
				// Add the set to the batch
				batch.setData(data, forDocument: team.ref)
			} else {
				// Add the update to the batch
				batch.updateData(data, forDocument: team.ref)
			}
			
		}
		
		// Save batch
		batch.commit { (error: Error?) in
			
			if let error = error {
				
				print(error)
				
				// Error retry
				self.present(ErrorRetryController(message: "Failed to save teams.", onRetry: {
					
					self.doSave()
					
				}), animated: true, completion: nil)
				
			} else {
				
				// All docs have been created. They must be updated, not set.
				self.teams.forEach { $0.needToCreateDoc = false }
				
			}
			
		}
	}
	
}

class SetupTeam {
	
	var deleted: Bool = false
	var needToCreateDoc: Bool
	
	let ref: DocumentReference
	private(set) var name: String
	private(set) var emails: [String]
	
	init(ref: DocumentReference, name: String) {
		self.ref = ref
		self.name = name
		self.emails = []
		self.needToCreateDoc = true
	}
	
	init?(ref: DocumentReference, json: JSONObject) {
		guard let name = json["name"].string else {
			return nil
		}
		
		guard let emails = json["members"].array else {
			return nil
		}
		
		self.ref = ref
		self.name = name
		self.emails = emails.compactMap { $0.string }
		self.needToCreateDoc = false
	}
	
	func setName(to name: String) {
		self.name = name
	}
	
	func contains(email: String) -> Bool {
		return self.emails.contains(email.lowercased())
	}
	
	func insert(email: String) {
		self.emails.append(email.lowercased())
	}
	
	func remove(email: String) {
		self.emails.removeAll { $0 == email.lowercased() }
	}
	
}
