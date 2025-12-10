//
//  ArcadeDialectViewController.swift
//  GapRunner
//
//  Created by Zhao on 2025/12/10.
//

import UIKit

final class ArcadeDialectViewController: UIViewController {
    
    private let nebulaBack = NebulaBackButton()
    private let gridStack = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        installAuroraBackdrop()
        configureBack()
        configureCards()
        layoutViews()
    }
    
    private func configureBack() {
        nebulaBack.addTarget(self, action: #selector(closeSelf), for: .touchUpInside)
        nebulaBack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nebulaBack)
    }
    
    private func configureCards() {
        gridStack.axis = .vertical
        gridStack.spacing = 22
        gridStack.distribution = .fillEqually
        gridStack.translatesAutoresizingMaskIntoConstraints = false
        
        let uniformCard = makeCard(
            title: "Harmonic Loop",
            icon: "circle.hexagongrid.fill",
            buttonTitle: "Start Loop",
            colors: [.auroraTeal, .auroraYellow],
            action: #selector(startUniform)
        )
        let diverseCard = makeCard(
            title: "Prismatic Run",
            icon: "wand.and.stars.inverse",
            buttonTitle: "Start Run",
            colors: [.auroraMagenta, .auroraTeal],
            action: #selector(startDiverse)
        )
        
        gridStack.addArrangedSubview(uniformCard)
        gridStack.addArrangedSubview(diverseCard)
        view.addSubview(gridStack)
    }
    
    private func layoutViews() {
        NSLayoutConstraint.activate([
            nebulaBack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            nebulaBack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nebulaBack.widthAnchor.constraint(equalToConstant: 44),
            nebulaBack.heightAnchor.constraint(equalToConstant: 44),
            
            gridStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            gridStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            gridStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            gridStack.heightAnchor.constraint(equalToConstant: 320)
        ])
    }
    
    private func makeCard(title: String,
                          icon: String,
                          buttonTitle: String,
                          colors: [UIColor],
                          action: Selector) -> UIView {
        let container = UIView()
        container.layer.cornerRadius = 24
        container.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        container.layer.borderWidth = 2
        container.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        
        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = .white
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let actionButton = CelestialButton(title: buttonTitle, colors: colors)
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.addTarget(self, action: action, for: .touchUpInside)
        
        container.addSubview(iconView)
        container.addSubview(titleLabel)
        container.addSubview(actionButton)
        
        NSLayoutConstraint.activate([
            iconView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            iconView.topAnchor.constraint(equalTo: container.topAnchor, constant: 24),
            iconView.widthAnchor.constraint(equalToConstant: 50),
            iconView.heightAnchor.constraint(equalToConstant: 50),
            
            titleLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: container.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -20),
            
            actionButton.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            actionButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            actionButton.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -20),
            actionButton.heightAnchor.constraint(equalToConstant: 54)
        ])
        
        return container
    }
    
    @objc private func startUniform() {
        launchGameplay(mode: .uniform)
    }
    
    @objc private func startDiverse() {
        launchGameplay(mode: .diverse)
    }
    
    private func launchGameplay(mode: GameplayModeVariant) {
        let gameplay = FluxCarouselViewController(mode: mode)
        gameplay.modalPresentationStyle = .fullScreen
        present(gameplay, animated: true)
    }
    
    @objc private func closeSelf() {
        dismiss(animated: true)
    }
    
    override var prefersStatusBarHidden: Bool { true }
}


