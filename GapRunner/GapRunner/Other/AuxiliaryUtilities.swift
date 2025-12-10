//
//  AuxiliaryUtilities.swift
//  GapRunner
//
//  Created by Zhao on 2025/11/28.
//

import UIKit

// MARK: - Color Palette
extension UIColor {
    static let primaryAccent = UIColor(red: 0.2, green: 0.5, blue: 0.9, alpha: 1.0)
    static let secondaryAccent = UIColor(red: 0.9, green: 0.6, blue: 0.2, alpha: 1.0)
    static let shadowTint = UIColor(white: 0, alpha: 0.3)
    static let overlayDimmed = UIColor(white: 0, alpha: 0.3)
    static let successGreen = UIColor(red: 0.2, green: 0.8, blue: 0.4, alpha: 1.0)
    static let dangerRed = UIColor(red: 0.9, green: 0.3, blue: 0.3, alpha: 1.0)
}

// MARK: - Custom Button
class EnhancedActionButton: UIButton {
    
    init(title: String, backgroundColor: UIColor = .primaryAccent) {
        super.init(frame: .zero)
        configureAppearance(title: title, bgColor: backgroundColor)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureAppearance(title: String, bgColor: UIColor) {
        setTitle(title, for: .normal)
        setTitleColor(.white, for: .normal)
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        backgroundColor = bgColor
        layer.cornerRadius = 12
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 8
        layer.shadowOpacity = 0.3
        
        addTarget(self, action: #selector(buttonTouched), for: .touchDown)
        addTarget(self, action: #selector(buttonReleased), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }
    
    @objc func buttonTouched() {
        UIView.animate(withDuration: 0.1) {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }
    
    @objc func buttonReleased() {
        UIView.animate(withDuration: 0.1) {
            self.transform = .identity
        }
    }
}

// MARK: - Custom Navigation Button
class NavigationReturnButton: UIButton {
    
    init() {
        super.init(frame: .zero)
        setupDesign()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupDesign() {
        backgroundColor = UIColor.white.withAlphaComponent(0.2)
        layer.cornerRadius = 20
        layer.borderWidth = 2
        layer.borderColor = UIColor.white.cgColor
        
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)
        let image = UIImage(systemName: "arrow.left", withConfiguration: config)
        setImage(image, for: .normal)
        tintColor = .white
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.3
    }
}

// MARK: - Persistent Storage Manager
class PersistenceCoordinator {
    
    static let shared = PersistenceCoordinator()
    let recordsKey = "GameAchievementRecords"
    
    func archiveRecord(_ record: GameAchievementRecord) {
        var existingRecords = retrieveAllRecords()
        existingRecords.append(record)
        
        if let encodedData = try? JSONEncoder().encode(existingRecords) {
            UserDefaults.standard.set(encodedData, forKey: recordsKey)
        }
    }
    
    func retrieveAllRecords() -> [GameAchievementRecord] {
        guard let data = UserDefaults.standard.data(forKey: recordsKey),
              let records = try? JSONDecoder().decode([GameAchievementRecord].self, from: data) else {
            return []
        }
        return records.sorted { $0.timestamp > $1.timestamp }
    }
    
    func eliminateRecord(withIdentifier id: String) {
        var records = retrieveAllRecords()
        records.removeAll { $0.recordIdentifier == id }
        
        if let encodedData = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(encodedData, forKey: recordsKey)
        }
    }
    
    func purgeAllRecords() {
        UserDefaults.standard.removeObject(forKey: recordsKey)
    }
}

// MARK: - Background Image View Extension
extension UIViewController {
    
    func installBackgroundImagery() {
        let backgroundImageView = UIImageView(image: UIImage(named: "runnerImage"))
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.frame = view.bounds
        backgroundImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(backgroundImageView)
        view.sendSubviewToBack(backgroundImageView)
        
        let overlayView = UIView(frame: view.bounds)
        overlayView.backgroundColor = UIColor.overlayDimmed
        overlayView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(overlayView)
        view.sendSubviewToBack(overlayView)
    }
}

// MARK: - Tile Image View
class TileImageViewComponent: UIImageView {
    
    let tileEntity: MahjongTileEntity
    
    init(tile: MahjongTileEntity) {
        self.tileEntity = tile
        super.init(frame: .zero)
        configureStyling()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureStyling() {
        image = tileEntity.tileImage
        contentMode = .scaleToFill
        layer.cornerRadius = 6
        layer.masksToBounds = true
        layer.borderWidth = 2
        layer.borderColor = UIColor.white.cgColor
        isUserInteractionEnabled = true
    }
    
    func animateSelection() {
        UIView.animate(withDuration: 0.15, animations: {
            self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            self.alpha = 0.6
        }) { _ in
            UIView.animate(withDuration: 0.15) {
                self.transform = .identity
                self.alpha = 1.0
            }
        }
    }
    
    func animateCorrectChoice() {
        UIView.animate(withDuration: 0.3, animations: {
            self.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            self.alpha = 0
        }) { _ in
            self.removeFromSuperview()
        }
    }
    
    func animateIncorrectShake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.5
        animation.values = [-10, 10, -8, 8, -5, 5, 0]
        layer.add(animation, forKey: "shake")
    }
}

