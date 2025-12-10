//
//  ChronicleVaultViewController.swift
//  GapRunner
//
//  Created by Zhao on 2025/12/10.
//

import UIKit

final class ChronicleVaultViewController: UIViewController {
    
    private var records: [VoyageRegister] = []
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let emptyLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .auroraMidnight
        configureNav()
        configureTable()
        configureEmptyState()
        loadRecords()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadRecords()  // 页面显示时刷新数据
    }
    
    private func configureNav() {
        title = "Chronicle Vault"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = .white
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .auroraSlate
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Close",
            style: .plain,
            target: self,
            action: #selector(closeSelf))
        
        let clearButton = UIBarButtonItem(
            title: "Clear",
            style: .plain,
            target: self,
            action: #selector(clearAll))
        clearButton.tintColor = .systemRed
        navigationItem.rightBarButtonItem = clearButton
    }
    
    private func configureTable() {
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.register(ChronicleCell.self, forCellReuseIdentifier: "ChronicleCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    /// 配置空状态占位符
    private func configureEmptyState() {
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.text = "No records yet.\nComplete a game to see your achievements here."
        emptyLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        emptyLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        emptyLabel.numberOfLines = 0
        emptyLabel.textAlignment = .center
        emptyLabel.isHidden = true  // 初始隐藏
        view.addSubview(emptyLabel)
        
        NSLayoutConstraint.activate([
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            emptyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
    }
    
    private func loadRecords() {
        records = ChronicleArchivist.shared.fetchRecords()
        emptyLabel.isHidden = !records.isEmpty  // 根据数据显示/隐藏占位符
        tableView.reloadData()
    }
    
    @objc private func closeSelf() {
        dismiss(animated: true)
    }
    
    @objc private func clearAll() {
        guard !records.isEmpty else { return }
        
        let alert = UIAlertController(
            title: "Clear All Records?",
            message: "This action cannot be undone.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Clear", style: .destructive) { [weak self] _ in
            ChronicleArchivist.shared.wipeAll()
            self?.loadRecords()
        })
        
        present(alert, animated: true)
    }
}

extension ChronicleVaultViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return records.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChronicleCell", for: indexPath) as! ChronicleCell
        cell.configure(with: records[indexPath.row], index: indexPath.row + 1)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { true }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            ChronicleArchivist.shared.delete(record: records[indexPath.row])
            loadRecords()
        }
    }
}

final class ChronicleCell: UITableViewCell {
    
    private let container = UIView()
    private let rankLabel = UILabel()
    private let scoreLabel = UILabel()
    private let modeLabel = UILabel()
    private let dateLabel = UILabel()
    private let durationLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        container.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        container.layer.cornerRadius = 20
        container.layer.borderWidth = 1.5
        container.layer.borderColor = UIColor.auroraTeal.cgColor
        container.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(container)
        
        [rankLabel, scoreLabel, modeLabel, dateLabel, durationLabel].forEach {
            $0.textColor = .white
            $0.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview($0)
        }
        
        rankLabel.font = UIFont.systemFont(ofSize: 32, weight: .heavy)
        scoreLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        modeLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        dateLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        durationLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 16, weight: .medium)
        
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            
            rankLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            rankLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 20),
            
            scoreLabel.leadingAnchor.constraint(equalTo: rankLabel.trailingAnchor, constant: 16),
            scoreLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 18),
            
            modeLabel.leadingAnchor.constraint(equalTo: scoreLabel.leadingAnchor),
            modeLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 8),
            
            dateLabel.leadingAnchor.constraint(equalTo: scoreLabel.leadingAnchor),
            dateLabel.topAnchor.constraint(equalTo: modeLabel.bottomAnchor, constant: 8),
            
            durationLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            durationLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -20)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with record: VoyageRegister, index: Int) {
        rankLabel.text = "#\(index)"
        scoreLabel.text = "Score: \(record.terminalScore)"
        modeLabel.text = record.schemeDescription
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        dateLabel.text = formatter.string(from: record.imprintDate)
        let minutes = record.elapsedSeconds / 60
        let seconds = record.elapsedSeconds % 60
        durationLabel.text = String(format: "%02d:%02d", minutes, seconds)
    }
}


