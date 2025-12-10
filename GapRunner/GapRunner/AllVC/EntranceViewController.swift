//
//  EntranceViewController.swift
//  GapRunner
//
//  Created by Zhao on 2025/11/28.
//

import UIKit

class EntranceViewController: UIViewController {
    
    let commenceGameButton = EnhancedActionButton(title: "Start Game")
    let viewRecordsButton = EnhancedActionButton(title: "Game Records", backgroundColor: .secondaryAccent)
    let instructionsButton = EnhancedActionButton(title: "How to Play", backgroundColor: UIColor.systemPurple)
    let buttonStackView = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        installBackgroundImagery()
        assembleInterface()
        configureConstraints()
    }
    
    func assembleInterface() {
        commenceGameButton.addTarget(self, action: #selector(initiateGameplay), for: .touchUpInside)
        viewRecordsButton.addTarget(self, action: #selector(displayRecordsArchive), for: .touchUpInside)
        instructionsButton.addTarget(self, action: #selector(presentInstructions), for: .touchUpInside)
        
        buttonStackView.axis = .vertical
        buttonStackView.spacing = 20
        buttonStackView.distribution = .fillEqually
        buttonStackView.addArrangedSubview(commenceGameButton)
        buttonStackView.addArrangedSubview(viewRecordsButton)
        buttonStackView.addArrangedSubview(instructionsButton)
        view.addSubview(buttonStackView)
    }
    
    func configureConstraints() {
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            buttonStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            buttonStackView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    @objc func initiateGameplay() {
        let modeSelector = ModeSelectionViewController()
        modeSelector.modalPresentationStyle = .fullScreen
        present(modeSelector, animated: true)
    }
    
    @objc func displayRecordsArchive() {
        let recordsVC = AchievementRecordsViewController()
        let navController = UINavigationController(rootViewController: recordsVC)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }
    
    @objc func presentInstructions() {
        let instructionsVC = InstructionsViewController()
        instructionsVC.modalPresentationStyle = .fullScreen
        present(instructionsVC, animated: true)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

