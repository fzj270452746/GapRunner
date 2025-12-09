//
//  InstructionsViewController.swift
//  GapRunner
//
//  Created by Zhao on 2025/11/28.
//

import UIKit

class InstructionsViewController: UIViewController {
    
    let scrollView = UIScrollView()
    let contentStackView = UIStackView()
    let returnButton = NavigationReturnButton()
    let titleLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        installBackgroundImagery()
        assembleInterface()
        configureConstraints()
        populateInstructions()
    }
    
    func assembleInterface() {
        returnButton.addTarget(self, action: #selector(dismissViewController), for: .touchUpInside)
        view.addSubview(returnButton)
        
        titleLabel.text = "How to Play"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 32)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.layer.shadowColor = UIColor.black.cgColor
        titleLabel.layer.shadowOffset = CGSize(width: 0, height: 2)
        titleLabel.layer.shadowRadius = 4
        titleLabel.layer.shadowOpacity = 0.7
        view.addSubview(titleLabel)
        
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)
        
        contentStackView.axis = .vertical
        contentStackView.spacing = 25
        contentStackView.alignment = .fill
        contentStackView.distribution = .equalSpacing
        scrollView.addSubview(contentStackView)
    }
    
    func configureConstraints() {
        returnButton.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let isPad = UIDevice.current.userInterfaceIdiom == .pad
        let sideMargin: CGFloat = isPad ? 100 : 30
        
        NSLayoutConstraint.activate([
            returnButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            returnButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            returnButton.widthAnchor.constraint(equalToConstant: 40),
            returnButton.heightAnchor.constraint(equalToConstant: 40),
            
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 70),
            
            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: sideMargin),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -sideMargin),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    func populateInstructions() {
        let sections = [
            InstructionSection(
                title: "Game Objective",
                description: "Fill the gaps in the moving tile sequence by selecting correct tiles from the bottom panel to form consecutive numbers."
            ),
            InstructionSection(
                title: "How to Play",
                description: "Watch the upper track where tiles move from right to left. Tap tiles from the bottom panel to fill the gaps. Example: If you see 2 [gap] 4, select tile 3."
            ),
            InstructionSection(
                title: "Uniform Mode",
                description: "All tiles are from the same category. Bottom panel shows 9 tiles in a 3×3 grid. Match both category and numbers."
            ),
            InstructionSection(
                title: "Diverse Mode",
                description: "Mixed category tiles. Bottom panel shows 30 tiles in a 5×6 grid. Only numbers need to match, not categories."
            ),
            InstructionSection(
                title: "Scoring",
                description: "Earn 10 points per correct tile. Start with 5 lives. Lose a life for wrong selection or missed sequence."
            )
        ]
        
        for section in sections {
            let sectionView = createInstructionSectionView(section)
            contentStackView.addArrangedSubview(sectionView)
        }
    }
    
    func createInstructionSectionView(_ section: InstructionSection) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = UIColor.white.withAlphaComponent(0.25)
        containerView.layer.cornerRadius = 16
        containerView.layer.borderWidth = 2
        containerView.layer.borderColor = UIColor.white.withAlphaComponent(0.4).cgColor
        
        let titleLabel = UILabel()
        titleLabel.text = section.title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 22)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 0
        titleLabel.layer.shadowColor = UIColor.black.cgColor
        titleLabel.layer.shadowOffset = CGSize(width: 0, height: 2)
        titleLabel.layer.shadowRadius = 4
        titleLabel.layer.shadowOpacity = 0.6
        containerView.addSubview(titleLabel)
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = section.description
        descriptionLabel.font = UIFont.systemFont(ofSize: 17)
        descriptionLabel.textColor = .white
        descriptionLabel.numberOfLines = 0
        descriptionLabel.layer.shadowColor = UIColor.black.cgColor
        descriptionLabel.layer.shadowOffset = CGSize(width: 0, height: 1)
        descriptionLabel.layer.shadowRadius = 3
        descriptionLabel.layer.shadowOpacity = 0.5
        containerView.addSubview(descriptionLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            descriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            descriptionLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20)
        ])
        
        return containerView
    }
    
    @objc func dismissViewController() {
        dismiss(animated: true)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

struct InstructionSection {
    let title: String
    let description: String
}

