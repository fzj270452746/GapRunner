//
//  AchievementRecordsViewController.swift
//  GapRunner
//
//  Created by Zhao on 2025/11/28.
//

import UIKit

class AchievementRecordsViewController: UIViewController {
    
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    let emptyStateLabel = UILabel()
    var recordsCollection: [GameAchievementRecord] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        installBackgroundImagery()
        configureNavigationAppearance()
        assembleInterface()
        configureConstraints()
        loadRecordsData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadRecordsData()
    }
    
    func configureNavigationAppearance() {
        title = "Game Records"
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white, .font: UIFont.boldSystemFont(ofSize: 20)]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Clear All",
            style: .plain,
            target: self,
            action: #selector(confirmPurgeAllRecords)
        )
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Close",
            style: .plain,
            target: self,
            action: #selector(dismissViewController)
        )
    }
    
    func assembleInterface() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.register(RecordTableCell.self, forCellReuseIdentifier: "RecordCell")
        tableView.separatorStyle = .none
        view.addSubview(tableView)
        
        emptyStateLabel.text = "No game records yet.\nPlay a game to create records!"
        emptyStateLabel.font = UIFont.systemFont(ofSize: 18)
        emptyStateLabel.textColor = .white
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.numberOfLines = 0
        emptyStateLabel.alpha = 0.8
        emptyStateLabel.isHidden = true
        view.addSubview(emptyStateLabel)
    }
    
    func configureConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
    }
    
    func loadRecordsData() {
        recordsCollection = PersistenceCoordinator.shared.retrieveAllRecords()
        emptyStateLabel.isHidden = !recordsCollection.isEmpty
        tableView.reloadData()
    }
    
    @objc func confirmPurgeAllRecords() {
        guard !recordsCollection.isEmpty else { return }
        
        let alert = UIAlertController(
            title: "Clear All Records?",
            message: "This action cannot be undone",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Clear", style: .destructive) { [weak self] _ in
            PersistenceCoordinator.shared.purgeAllRecords()
            self?.loadRecordsData()
        })
        present(alert, animated: true)
    }
    
    @objc func dismissViewController() {
        dismiss(animated: true)
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension AchievementRecordsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recordsCollection.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecordCell", for: indexPath) as! RecordTableCell
        let record = recordsCollection[indexPath.row]
        cell.configureWithRecord(record, forNumber: indexPath.row + 1)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let record = recordsCollection[indexPath.row]
            PersistenceCoordinator.shared.eliminateRecord(withIdentifier: record.recordIdentifier)
            loadRecordsData()
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Delete"
    }
}

// MARK: - Custom Table Cell
class RecordTableCell: UITableViewCell {
    
    let containerView = UIView()
    let rankLabel = UILabel()
    let scoreLabel = UILabel()
    let modeLabel = UILabel()
    let dateLabel = UILabel()
    let durationLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        assembleCellInterface()
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func assembleCellInterface() {
        backgroundColor = .clear
        selectionStyle = .none
        
        containerView.backgroundColor = UIColor.white.withAlphaComponent(0.25)
        containerView.layer.cornerRadius = 12
        containerView.layer.borderWidth = 2
        containerView.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
        contentView.addSubview(containerView)
        
        rankLabel.font = UIFont.boldSystemFont(ofSize: 32)
        rankLabel.textColor = .systemYellow
        rankLabel.textAlignment = .center
        rankLabel.layer.shadowColor = UIColor.black.cgColor
        rankLabel.layer.shadowOffset = CGSize(width: 0, height: 2)
        rankLabel.layer.shadowRadius = 3
        rankLabel.layer.shadowOpacity = 0.6
        containerView.addSubview(rankLabel)
        
        scoreLabel.font = UIFont.boldSystemFont(ofSize: 24)
        scoreLabel.textColor = .white
        scoreLabel.layer.shadowColor = UIColor.black.cgColor
        scoreLabel.layer.shadowOffset = CGSize(width: 0, height: 2)
        scoreLabel.layer.shadowRadius = 3
        scoreLabel.layer.shadowOpacity = 0.6
        containerView.addSubview(scoreLabel)
        
        modeLabel.font = UIFont.systemFont(ofSize: 16)
        modeLabel.textColor = .white
        modeLabel.layer.shadowColor = UIColor.black.cgColor
        modeLabel.layer.shadowOffset = CGSize(width: 0, height: 1)
        modeLabel.layer.shadowRadius = 2
        modeLabel.layer.shadowOpacity = 0.5
        containerView.addSubview(modeLabel)
        
        dateLabel.font = UIFont.systemFont(ofSize: 14)
        dateLabel.textColor = UIColor.white.withAlphaComponent(0.95)
        dateLabel.layer.shadowColor = UIColor.black.cgColor
        dateLabel.layer.shadowOffset = CGSize(width: 0, height: 1)
        dateLabel.layer.shadowRadius = 2
        dateLabel.layer.shadowOpacity = 0.5
        containerView.addSubview(dateLabel)
        
        durationLabel.font = UIFont.systemFont(ofSize: 14)
        durationLabel.textColor = UIColor.white.withAlphaComponent(0.95)
        durationLabel.layer.shadowColor = UIColor.black.cgColor
        durationLabel.layer.shadowOffset = CGSize(width: 0, height: 1)
        durationLabel.layer.shadowRadius = 2
        durationLabel.layer.shadowOpacity = 0.5
        containerView.addSubview(durationLabel)
    }
    
    func configureConstraints() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        rankLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        modeLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            rankLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 13),
            rankLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            rankLabel.widthAnchor.constraint(equalToConstant: 40),
            
            scoreLabel.leadingAnchor.constraint(equalTo: rankLabel.trailingAnchor, constant: 16),
            scoreLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            
            modeLabel.leadingAnchor.constraint(equalTo: rankLabel.trailingAnchor, constant: 16),
            modeLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 8),
            
            dateLabel.leadingAnchor.constraint(equalTo: rankLabel.trailingAnchor, constant: 16),
            dateLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            
            durationLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            durationLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        ])
    }
    
    func configureWithRecord(_ record: GameAchievementRecord, forNumber: Int) {
        rankLabel.text = "\(forNumber)"
        scoreLabel.text = "Score: \(record.scoreObtained)"
        modeLabel.text = record.gameModeType
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        dateLabel.text = formatter.string(from: record.timestamp)
        
        let minutes = record.durationInSeconds / 60
        let seconds = record.durationInSeconds % 60
        durationLabel.text = String(format: "%02d:%02d", minutes, seconds)
    }
}

