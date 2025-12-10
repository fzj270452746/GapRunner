//
//  ModeSelectionViewController.swift
//  GapRunner
//
//  Created by Zhao on 2025/11/28.
//

import UIKit

class ModeSelectionViewController: UIViewController {
    
    let returnButton = NavigationReturnButton()
    let modesStackView = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        installBackgroundImagery()
        assembleInterface()
        configureConstraints()
    }
    
    func assembleInterface() {
        returnButton.addTarget(self, action: #selector(dismissViewController), for: .touchUpInside)
        view.addSubview(returnButton)
        
        // Create mode cards
        let uniformCard = createModeCard(
            icon: "square.grid.3x3.fill",
            title: "Harmonic Loop",
            gradientColors: [UIColor.systemIndigo, UIColor.systemPurple],
            action: #selector(selectUniformMode)
        )
        
        let diverseCard = createModeCard(
            icon: "square.grid.3x3.topleft.filled",
            title: "Prismatic Run",
            gradientColors: [UIColor.systemOrange, UIColor.systemPink],
            action: #selector(selectDiverseMode)
        )
        
        modesStackView.axis = .vertical
        modesStackView.spacing = 25
        modesStackView.distribution = .fillEqually
        modesStackView.addArrangedSubview(uniformCard)
        modesStackView.addArrangedSubview(diverseCard)
        view.addSubview(modesStackView)
    }
    
    func createModeCard(icon: String, title: String, gradientColors: [UIColor], action: Selector) -> UIView {
        // Container for shadow
        let containerView = UIView()
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 8)
        containerView.layer.shadowRadius = 16
        containerView.layer.shadowOpacity = 0.4
        
        let cardView = GradientCardView(colors: gradientColors)
        cardView.layer.cornerRadius = 20
        cardView.layer.borderWidth = 2
        cardView.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        cardView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(cardView)
        
        // Icon
        let iconImageView = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 50, weight: .medium)
        iconImageView.image = UIImage(systemName: icon, withConfiguration: config)
        iconImageView.tintColor = .white
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(iconImageView)
        
        // Title
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 26)
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: containerView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            iconImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 25),
            iconImageView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 60),
            iconImageView.heightAnchor.constraint(equalToConstant: 60),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 20),
            titleLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20)
        ])
        
        // Add tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: action)
        containerView.addGestureRecognizer(tapGesture)
        containerView.isUserInteractionEnabled = true
        
        // Add touch animation
        containerView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(handleCardPress(_:))))
        
        return containerView
    }
    
    @objc func handleCardPress(_ gesture: UILongPressGestureRecognizer) {
        guard let containerView = gesture.view else { return }
        
        switch gesture.state {
        case .began:
            UIView.animate(withDuration: 0.1) {
                containerView.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
                containerView.layer.shadowOpacity = 0.2
            }
        case .ended, .cancelled:
            UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseOut) {
                containerView.transform = .identity
                containerView.layer.shadowOpacity = 0.4
            }
        default:
            break
        }
    }
    
    
    func configureConstraints() {
        returnButton.translatesAutoresizingMaskIntoConstraints = false
        modesStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let isPad = UIDevice.current.userInterfaceIdiom == .pad
        let sideMargin: CGFloat = isPad ? 100 : 30
        let cardHeight: CGFloat = isPad ? 160 : 130
        
        NSLayoutConstraint.activate([
            returnButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            returnButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            returnButton.widthAnchor.constraint(equalToConstant: 40),
            returnButton.heightAnchor.constraint(equalToConstant: 40),
            
            modesStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            modesStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            modesStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: sideMargin),
            modesStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -sideMargin),
            modesStackView.heightAnchor.constraint(equalToConstant: cardHeight * 2 + 25)
        ])
    }
    
    @objc func selectUniformMode() {
        launchGameplay(mode: .uniform)
    }
    
    @objc func selectDiverseMode() {
        launchGameplay(mode: .diverse)
    }
    
    func launchGameplay(mode: GameplayMode) {
        let gameVC = GameplayOrchestrationViewController(gameMode: mode)
        gameVC.modalPresentationStyle = .fullScreen
        present(gameVC, animated: true)
    }
    
    @objc func dismissViewController() {
        dismiss(animated: true)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

// MARK: - Gradient Card View
class GradientCardView: UIView {
    
    let gradientLayer = CAGradientLayer()
    
    init(colors: [UIColor]) {
        super.init(frame: .zero)
        gradientLayer.colors = colors.map { $0.withAlphaComponent(0.85).cgColor }
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.cornerRadius = 20
        layer.insertSublayer(gradientLayer, at: 0)
        clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
}

