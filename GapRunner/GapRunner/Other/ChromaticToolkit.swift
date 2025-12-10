//
//  ChromaticToolkit.swift
//  GapRunner
//
//  Created by Zhao on 2025/12/10.
//

import UIKit

// MARK: - Palette
extension UIColor {
    static let auroraMidnight = UIColor(red: 16/255, green: 18/255, blue: 38/255, alpha: 1.0)
    static let auroraTeal = UIColor(red: 78/255, green: 205/255, blue: 196/255, alpha: 1.0)
    static let auroraMagenta = UIColor(red: 208/255, green: 81/255, blue: 149/255, alpha: 1.0)
    static let auroraYellow = UIColor(red: 250/255, green: 210/255, blue: 97/255, alpha: 1.0)
    static let auroraSlate = UIColor(red: 38/255, green: 46/255, blue: 68/255, alpha: 1.0)
    static let glassFog = UIColor(white: 1.0, alpha: 0.15)
}

// MARK: - Button
final class CelestialButton: UIButton {
    
    private let gradientLayer = CAGradientLayer()
    
    init(title: String, colors: [UIColor]) {
        super.init(frame: .zero)
        setupGradient(colors: colors)
        configure(title: title)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupGradient(colors: [UIColor]) {
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.cornerRadius = 18
        layer.insertSublayer(gradientLayer, at: 0)
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 6)
        layer.shadowRadius = 12
        layer.shadowOpacity = 0.35
    }
    
    private func configure(title: String) {
        setTitle(title, for: .normal)
        setTitleColor(.white, for: .normal)
        titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        layer.cornerRadius = 18
        clipsToBounds = true
        addTarget(self, action: #selector(onPress), for: .touchDown)
        addTarget(self, action: #selector(onRelease), for: [.touchUpInside, .touchCancel, .touchDragExit])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
    
    @objc private func onPress() {
        UIView.animate(withDuration: 0.1) {
            self.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
        }
    }
    
    @objc private func onRelease() {
        UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseOut) {
            self.transform = .identity
        }
    }
}

// MARK: - Back Button
final class NebulaBackButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        backgroundColor = UIColor.white.withAlphaComponent(0.2)
        layer.cornerRadius = 22
        layer.borderWidth = 2
        layer.borderColor = UIColor.white.withAlphaComponent(0.7).cgColor
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        setImage(UIImage(systemName: "chevron.backward", withConfiguration: config), for: .normal)
        tintColor = .white
    }
}

// MARK: - Storage
final class ChronicleArchivist {
    
    static let shared = ChronicleArchivist()
    private let storageKey = "voyage_records_key"
    
    func save(record: VoyageRegister) {
        var bundle = fetchRecords()
        bundle.append(record)
        persist(bundle)
    }
    
    func fetchRecords() -> [VoyageRegister] {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([VoyageRegister].self, from: data) else {
            return []
        }
        return decoded.sorted { $0.imprintDate > $1.imprintDate }
    }
    
    func wipeAll() {
        UserDefaults.standard.removeObject(forKey: storageKey)
    }
    
    func delete(record: VoyageRegister) {
        let filtered = fetchRecords().filter { $0 != record }
        persist(filtered)
    }
    
    private func persist(_ records: [VoyageRegister]) {
        if let encoded = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
}

// MARK: - ZenithPalette
/// ZenithPalette - 为 HistoryLedgerController 等组件提供调色板支持
struct ZenithPalette {
    static let veil = UIColor.auroraSlate
    static let slate = UIColor.auroraSlate
    static let mint = UIColor.auroraTeal
    static let coral = UIColor.auroraMagenta
}

// MARK: - TypographyForge
/// TypographyForge - 字体工具类
struct TypographyForge {
    /// 创建标题字体
    static func titleFont(_ size: CGFloat, weight: UIFont.Weight = .heavy) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: weight)
    }
    
    /// 创建标签字体
    static func labelFont(_ size: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: weight)
    }
}

// MARK: - MonogramBackButton
/// MonogramBackButton - 为 PlaybookScrollController 提供支持
final class MonogramBackButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        backgroundColor = UIColor.white.withAlphaComponent(0.2)
        layer.cornerRadius = 23
        layer.borderWidth = 2
        layer.borderColor = UIColor.white.withAlphaComponent(0.7).cgColor
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        setImage(UIImage(systemName: "chevron.backward", withConfiguration: config), for: .normal)
        tintColor = .white
    }
}

// MARK: - ChronicleVault
/// ChronicleVault - 为 HistoryLedgerController 提供支持，ChronicleArchivist 的别名包装
final class ChronicleVault {
    static let shared = ChronicleVault()
    private let archivist = ChronicleArchivist.shared
    
    /// 获取所有记录
    func fetchAll() -> [VoyageRegister] {
        return archivist.fetchRecords()
    }
    
    /// 清空所有记录
    func clearAll() {
        archivist.wipeAll()
    }
    
    /// 根据ID删除记录
    func remove(id: String) {
        let records = archivist.fetchRecords()
        if let record = records.first(where: { $0.token == id }) {
            archivist.delete(record: record)
        }
    }
}

// MARK: - VoyageArchive Extension
/// VoyageArchive - 为 VoyageRegister 添加扩展属性
extension VoyageRegister {
    var identifier: String { return token }
    var variantTitle: String { return schemeDescription }
    var score: Int { return terminalScore }
    var accuracy: Double { return 0.85 } // 默认准确率
    var duration: TimeInterval { return TimeInterval(elapsedSeconds) }
    var recordedAt: Date { return imprintDate }
}

// MARK: - UIViewController Background
extension UIViewController {
    /// 安装 Aurora 背景
    func installAuroraBackdrop() {
        let backgroundView = UIImageView(image: UIImage(named: "runnerImage"))
        backgroundView.contentMode = .scaleAspectFill
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backgroundView)
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        let overlay = UIView()
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        overlay.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(overlay)
        NSLayoutConstraint.activate([
            overlay.topAnchor.constraint(equalTo: view.topAnchor),
            overlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            overlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    /// applyNebulaBackdrop 是 installAuroraBackdrop 的别名
    func applyNebulaBackdrop() {
        installAuroraBackdrop()
    }
}

// MARK: - Tile View
final class KaleidoTileView: UIImageView {
    
    let glyph: MosaicGlyphSpec
    
    init(glyph: MosaicGlyphSpec) {
        self.glyph = glyph
        super.init(frame: .zero)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        image = glyph.depiction
        contentMode = .scaleAspectFill
        layer.cornerRadius = 8
        layer.masksToBounds = true
        layer.borderWidth = 2
        layer.borderColor = UIColor.white.withAlphaComponent(0.8).cgColor
        isUserInteractionEnabled = true
    }
    
    func igniteSelection() {
        UIView.animate(withDuration: 0.12) {
            self.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
        } completion: { _ in
            UIView.animate(withDuration: 0.12) {
                self.transform = .identity
            }
        }
    }
}


