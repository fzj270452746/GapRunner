//
//  InstructionsViewController.swift
//  GapRunner
//
//  Created by Zhao on 2025/12/10.
//

import UIKit

/// PrimerSection - 教程章节结构
struct PrimerSection {
    let heading: String
    let narrative: String
}

/// InstructionsViewController - 游戏说明视图控制器
final class InstructionsViewController: UIViewController {
    private let backButton = MonogramBackButton()
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyNebulaBackdrop()
        configureBackButton()
        configureScroll()
        populateSections()
    }
    
    private func configureBackButton() {
        backButton.addTarget(self, action: #selector(closeSelf), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backButton)
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            backButton.widthAnchor.constraint(equalToConstant: 46),
            backButton.heightAnchor.constraint(equalToConstant: 46)
        ])
    }
    
    private func configureScroll() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)
        stackView.axis = .vertical
        stackView.spacing = 18
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 10),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func populateSections() {
        let sections = [
            PrimerSection(heading: "Objective",
                          narrative: "Observe the moving glyph track and fix the gaps with matching values to keep the flux stable."),
            PrimerSection(heading: "Controls",
                          narrative: "Tap a glyph tile in the lower grid to send it upward. Only the correct numerical order will lock into place."),
            PrimerSection(heading: "Mono Variant",
                          narrative: "Tiles come from a single clan. Use pattern recognition to anticipate the next gap."),
            PrimerSection(heading: "Mosaic Variant",
                          narrative: "All clans appear together. Ignore colors—focus purely on consecutive numbers."),
            PrimerSection(heading: "Scoring",
                          narrative: "Earn 10 points plus combo bonuses for each correct placement. Lives drop for mistakes or late responses."),
            PrimerSection(heading: "Tips",
                          narrative: "Track the first missing slot, let the rhythm guide you, and chase flawless accuracy for record-breaking runs.")
        ]
        sections.forEach { section in
            let card = makeCard(for: section)
            stackView.addArrangedSubview(card)
        }
    }
    
    private func makeCard(for section: PrimerSection) -> UIView {
        let container = UIView()
        container.backgroundColor = ZenithPalette.slate
        container.layer.cornerRadius = 18
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = section.heading
        titleLabel.font = TypographyForge.titleFont(24)
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let bodyLabel = UILabel()
        bodyLabel.text = section.narrative
        bodyLabel.numberOfLines = 0
        bodyLabel.font = TypographyForge.labelFont(16)
        bodyLabel.textColor = UIColor.white.withAlphaComponent(0.85)
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(titleLabel)
        container.addSubview(bodyLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 18),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 18),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -18),
            
            bodyLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            bodyLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            bodyLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            bodyLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -18)
        ])
        return container
    }
    
    @objc private func closeSelf() {
        dismiss(animated: true)
    }
    
    override var prefersStatusBarHidden: Bool { true }
}
