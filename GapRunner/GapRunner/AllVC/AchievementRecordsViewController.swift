//
//  AchievementRecordsViewController.swift
//  GapRunner
//
//  Created by Zhao on 2025/12/10.
//

import UIKit

/// AchievementRecordsViewController - 成就记录视图控制器
final class AchievementRecordsViewController: UIViewController {
    private let ledgerTable = UITableView(frame: .zero, style: .plain)
    private let emptyLabel = UILabel()
    private var archives: [VoyageRegister] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyNebulaBackdrop()
        configureNavigation()
        configureTable()
        configureEmptyState()
        refreshLedger()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshLedger()
    }
    
    private func configureNavigation() {
        title = "Voyage Ledger"
        navigationController?.navigationBar.tintColor = .white
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = ZenithPalette.veil
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white,
                                          .font: TypographyForge.labelFont(20, weight: .bold)]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close",
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(closeSelf))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Clear",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(clearAll))
    }
    
    private func configureTable() {
        ledgerTable.translatesAutoresizingMaskIntoConstraints = false
        ledgerTable.backgroundColor = .clear
        ledgerTable.separatorStyle = .none
        ledgerTable.rowHeight = 140
        ledgerTable.delegate = self
        ledgerTable.dataSource = self
        ledgerTable.register(LedgerRecordCell.self, forCellReuseIdentifier: LedgerRecordCell.identifier)
        view.addSubview(ledgerTable)
        NSLayoutConstraint.activate([
            ledgerTable.topAnchor.constraint(equalTo: view.topAnchor),
            ledgerTable.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            ledgerTable.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            ledgerTable.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func configureEmptyState() {
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.text = "No voyages yet.\nComplete a run to archive it."
        emptyLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        emptyLabel.font = TypographyForge.labelFont(18)
        emptyLabel.numberOfLines = 0
        emptyLabel.textAlignment = .center
        view.addSubview(emptyLabel)
        NSLayoutConstraint.activate([
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            emptyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30)
        ])
    }
    
    private func refreshLedger() {
        archives = ChronicleVault.shared.fetchAll()
        emptyLabel.isHidden = !archives.isEmpty
        ledgerTable.reloadData()
    }
    
    @objc private func closeSelf() {
        dismiss(animated: true)
    }
    
    @objc private func clearAll() {
        guard !archives.isEmpty else { return }
        let alert = UIAlertController(title: "Erase Entries?",
                                      message: "This cannot be undone",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Erase", style: .destructive, handler: { _ in
            ChronicleVault.shared.clearAll()
            self.refreshLedger()
        }))
        present(alert, animated: true)
    }
}

extension AchievementRecordsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        archives.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: LedgerRecordCell.identifier, for: indexPath) as? LedgerRecordCell else {
            return UITableViewCell()
        }
        cell.populate(with: archives[indexPath.row], rank: indexPath.row + 1)
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        let entry = archives[indexPath.row]
        ChronicleVault.shared.remove(id: entry.identifier)
        refreshLedger()
    }
}

/// LedgerRecordCell - 记录单元格
final class LedgerRecordCell: UITableViewCell {
    static let identifier = "LedgerRecordCell"
    private let container = UIView()
    private let rankLabel = UILabel()
    private let titleLabel = UILabel()
    private let scoreLabel = UILabel()
    private let accuracyLabel = UILabel()
    private let dateLabel = UILabel()
    private let durationLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        configureViews()
        layoutViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureViews() {
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = ZenithPalette.slate
        container.layer.cornerRadius = 18
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        contentView.addSubview(container)
        
        [rankLabel, titleLabel, scoreLabel, accuracyLabel, dateLabel, durationLabel].forEach { label in
            label.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(label)
            label.textColor = .white
        }
        rankLabel.font = TypographyForge.titleFont(30)
        titleLabel.font = TypographyForge.labelFont(18, weight: .bold)
        scoreLabel.font = TypographyForge.labelFont(16)
        accuracyLabel.font = TypographyForge.labelFont(16)
        dateLabel.font = TypographyForge.labelFont(14)
        durationLabel.font = TypographyForge.labelFont(14)
        accuracyLabel.textColor = ZenithPalette.mint
        scoreLabel.textColor = ZenithPalette.coral
    }
    
    private func layoutViews() {
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            rankLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 14),
            rankLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            rankLabel.widthAnchor.constraint(equalToConstant: 44),
            
            titleLabel.leadingAnchor.constraint(equalTo: rankLabel.trailingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 18),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            
            scoreLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            scoreLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            
            accuracyLabel.leadingAnchor.constraint(equalTo: scoreLabel.trailingAnchor, constant: 12),
            accuracyLabel.centerYAnchor.constraint(equalTo: scoreLabel.centerYAnchor),
            
            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            dateLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16),
            
            durationLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            durationLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16)
        ])
    }
    
    func populate(with archive: VoyageRegister, rank: Int) {
        rankLabel.text = "#\(rank)"
        titleLabel.text = archive.variantTitle
        scoreLabel.text = "Score \(archive.score)"
        let accuracyPercent = Int(archive.accuracy * 100)
        accuracyLabel.text = "Accuracy \(accuracyPercent)%"
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        dateLabel.text = formatter.string(from: archive.recordedAt)
        durationLabel.text = formatted(duration: archive.duration)
    }
    
    private func formatted(duration: TimeInterval) -> String {
        let totalSeconds = Int(duration)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
