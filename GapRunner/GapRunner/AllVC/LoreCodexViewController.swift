//
//  LoreCodexViewController.swift
//  GapRunner
//
//  Created by Zhao on 2025/12/10.
//

import UIKit

final class LoreCodexViewController: UIViewController {
    
    private let nebulaBack = NebulaBackButton()
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        installAuroraBackdrop()
        configureBack()
        configureScroll()
        populateSections()
        layoutViews()
    }
    
    private func configureBack() {
        nebulaBack.addTarget(self, action: #selector(closeSelf), for: .touchUpInside)
        nebulaBack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nebulaBack)
    }
    
    private func configureScroll() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        contentStack.axis = .vertical
        contentStack.spacing = 20
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)
    }
    
    private func populateSections() {
        let entries: [(String, String)] = [
            ("Objective", "Guide the drifting tiles to form seamless number runs. Fill every gap before the procession leaves the screen."),
            ("Controls", "Tap tiles from the lower reservoir to slot them into the glowing spaces above. Only the next required number is valid."),
            ("Harmonic Loop", "All tiles share the same clan. Focus on both suit and value to maintain the run."),
            ("Prismatic Run", "Clans intermingle freely. Match strictly by numbers to keep the sequence alive."),
            ("Scoring", "Earn 15 points for every accurate placement. Mistakes and missed sequences consume hearts. The voyage concludes when hearts fade.")
        ]
        
        for entry in entries {
            contentStack.addArrangedSubview(makeSection(title: entry.0, detail: entry.1))
        }
    }
    
    private func makeSection(title: String, detail: String) -> UIView {
        let card = UIView()
        card.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        card.layer.cornerRadius = 20
        card.layer.borderWidth = 1.5
        card.layer.borderColor = UIColor.auroraTeal.cgColor
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let detailLabel = UILabel()
        detailLabel.text = detail
        detailLabel.textColor = UIColor.white.withAlphaComponent(0.9)
        detailLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        detailLabel.numberOfLines = 0
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        
        card.addSubview(titleLabel)
        card.addSubview(detailLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 18),
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 18),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -18),
            
            detailLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            detailLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            detailLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            detailLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -18)
        ])
        
        return card
    }
    
    private func layoutViews() {
        NSLayoutConstraint.activate([
            nebulaBack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            nebulaBack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nebulaBack.widthAnchor.constraint(equalToConstant: 44),
            nebulaBack.heightAnchor.constraint(equalToConstant: 44),
            
            scrollView.topAnchor.constraint(equalTo: nebulaBack.bottomAnchor, constant: 12),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    @objc private func closeSelf() {
        dismiss(animated: true)
    }
    
    override var prefersStatusBarHidden: Bool { true }
}


