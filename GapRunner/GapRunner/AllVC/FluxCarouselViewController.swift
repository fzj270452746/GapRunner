//
//  FluxCarouselViewController.swift
//  GapRunner
//
//  Created by Zhao on 2025/12/10.
//

import UIKit

final class FluxCarouselViewController: UIViewController {
    
    private let mode: GameplayModeVariant
    
    // UI
    private let nebulaBack = NebulaBackButton()
    private let scoreBadge = UILabel()
    private let lifeBadge = UILabel()
    private let roundBadge = UILabel()
    private let upperRunway = UIView()
    private let lowerMatrix = UIView()
    
    // State
    private var score = 0
    private var lives = 5
    private var roundIndex = 0
    private var hasLaunched = false
    private var pendingValues: [Int] = []
    private var gapOrder: [Int] = []
    private var gapViews: [UIView] = []  // 存储空格视图，按照应填充的顺序
    private var glyphTrack: [UIView] = []
    private var matrixTiles: [KaleidoTileView] = []
    private var currentClan: MosaicGlyphFamily = .bamboo
    private var animator: UIViewPropertyAnimator?
    private var startDate = Date()
    
    private var gapHighlightIndex = 0
    
    init(mode: GameplayModeVariant) {
        self.mode = mode
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        installAuroraBackdrop()
        configureTopBar()
        configureRunway()
        configureMatrix()
        layoutViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !hasLaunched {
            hasLaunched = true
            beginNewRound()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        animator?.stopAnimation(true)
    }
    
    private func configureTopBar() {
        nebulaBack.addTarget(self, action: #selector(quitGame), for: .touchUpInside)
        nebulaBack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nebulaBack)
        
        [scoreBadge, lifeBadge, roundBadge].forEach {
            $0.font = UIFont.monospacedDigitSystemFont(ofSize: 18, weight: .bold)
            $0.textColor = .white
            $0.backgroundColor = UIColor.white.withAlphaComponent(0.2)
            $0.layer.cornerRadius = 14
            $0.layer.masksToBounds = true
            $0.textAlignment = .center
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.heightAnchor.constraint(equalToConstant: 34).isActive = true
            view.addSubview($0)
        }
        updateBadges()
    }
    
    private func configureRunway() {
        upperRunway.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        upperRunway.layer.cornerRadius = 18
        upperRunway.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(upperRunway)
    }
    
    private func configureMatrix() {
        lowerMatrix.backgroundColor = UIColor.auroraSlate.withAlphaComponent(0.6)
        lowerMatrix.layer.cornerRadius = 24
        lowerMatrix.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(lowerMatrix)
    }
    
    private func layoutViews() {
        NSLayoutConstraint.activate([
            nebulaBack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            nebulaBack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nebulaBack.widthAnchor.constraint(equalToConstant: 44),
            nebulaBack.heightAnchor.constraint(equalToConstant: 44),
            
            scoreBadge.leadingAnchor.constraint(equalTo: nebulaBack.trailingAnchor, constant: 12),
            scoreBadge.centerYAnchor.constraint(equalTo: nebulaBack.centerYAnchor),
            scoreBadge.widthAnchor.constraint(equalToConstant: 110),
            
            lifeBadge.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            lifeBadge.centerYAnchor.constraint(equalTo: nebulaBack.centerYAnchor),
            lifeBadge.widthAnchor.constraint(equalToConstant: 110),
            
            roundBadge.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            roundBadge.topAnchor.constraint(equalTo: nebulaBack.bottomAnchor, constant: 12),
            roundBadge.widthAnchor.constraint(equalToConstant: 110),
            
            upperRunway.topAnchor.constraint(equalTo: roundBadge.bottomAnchor, constant: 20),
            upperRunway.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            upperRunway.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            upperRunway.heightAnchor.constraint(equalToConstant: 140),
            
            lowerMatrix.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 26),
            lowerMatrix.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -26),
            lowerMatrix.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            lowerMatrix.heightAnchor.constraint(equalToConstant: 360)
        ])
    }
    
    private func beginNewRound() {
        roundIndex += 1
        updateBadges()
        glyphTrack.forEach { $0.removeFromSuperview() }
        glyphTrack.removeAll()
        matrixTiles.forEach { $0.removeFromSuperview() }
        matrixTiles.removeAll()
        gapOrder.removeAll()
        gapViews.removeAll()  // 清空空格视图数组
        pendingValues.removeAll()
        gapHighlightIndex = 0
        
        createRunwaySequence()
        populateMatrix()
        animateRunway()
    }
    
    private func createRunwaySequence() {
        let segments = Int.random(in: 3...7)
        let gaps = Int.random(in: 1...segments - 1)
        let start = Int.random(in: 1...(9 - segments + 1))
        currentClan = mode == .uniform ? HeptagramLedger.shared.randomClan() : .bamboo
        
        // 生成空格位置，确保不连续超过2个
        var gapPositions: [Int] = []
        var availablePositions = Array(0..<segments)
        var consecutiveCount = 0
        
        for _ in 0..<gaps {
            // 过滤掉会导致连续超过2个空格的位置
            let validPositions = availablePositions.filter { pos in
                // 检查添加这个位置后是否会导致连续超过2个
                let testPositions = (gapPositions + [pos]).sorted()
                return !hasMoreThanTwoConsecutive(testPositions)
            }
            
            if let selectedPos = validPositions.randomElement() {
                gapPositions.append(selectedPos)
                availablePositions.removeAll { $0 == selectedPos }
            }
        }
        gapPositions.sort()
        
        let spacing: CGFloat = 12
        let tileHeight: CGFloat = 100
        let tileWidth: CGFloat = tileHeight / 1.4
        var xCursor: CGFloat = upperRunway.bounds.width
        
        
        for index in 0..<segments {
            let tileValue = start + index
            let tileFrame = CGRect(x: xCursor, y: (upperRunway.bounds.height - tileHeight) / 2, width: tileWidth, height: tileHeight)
            let slotView = UIView(frame: tileFrame)
            slotView.layer.cornerRadius = 10
            slotView.layer.borderWidth = 2
            slotView.tag = tileValue  // 设置tag为数值，方便调试
            
            if gapPositions.contains(index) {
                gapOrder.append(tileValue)
                pendingValues.append(tileValue)
                gapViews.append(slotView)  // 将空格视图添加到数组中
                styleGap(slotView, highlighted: gapOrder.count == 1)
            } else {
                let clan = mode == .uniform ? currentClan : HeptagramLedger.shared.randomClan()
                if let glyph = HeptagramLedger.shared.suite(for: clan).first(where: { $0.numericValue == tileValue }) {
                    let tile = KaleidoTileView(glyph: glyph)
                    tile.frame = slotView.bounds
                    tile.isUserInteractionEnabled = false
                    slotView.addSubview(tile)
                    slotView.layer.borderColor = UIColor.clear.cgColor
                    slotView.backgroundColor = .clear
                }
            }
            
            upperRunway.addSubview(slotView)
            glyphTrack.append(slotView)
            xCursor += tileWidth + spacing
        }
        
    }
    
    /// 检查位置数组中是否有连续超过2个的情况
    private func hasMoreThanTwoConsecutive(_ positions: [Int]) -> Bool {
        guard positions.count >= 3 else { return false }
        let sorted = positions.sorted()
        for i in 0..<(sorted.count - 2) {
            if sorted[i+1] == sorted[i] + 1 && sorted[i+2] == sorted[i] + 2 {
                return true
            }
        }
        return false
    }
    
    private func styleGap(_ view: UIView, highlighted: Bool) {
        view.backgroundColor = highlighted ? UIColor.auroraYellow.withAlphaComponent(0.3) : UIColor.white.withAlphaComponent(0.12)
        view.layer.borderColor = highlighted ? UIColor.auroraYellow.cgColor : UIColor.white.withAlphaComponent(0.6).cgColor
        if highlighted {
            let pulse = CABasicAnimation(keyPath: "opacity")
            pulse.fromValue = 1.0
            pulse.toValue = 0.4
            pulse.duration = 0.8
            pulse.autoreverses = true
            pulse.repeatCount = .greatestFiniteMagnitude
            view.layer.add(pulse, forKey: "pulse-highlight")
        } else {
            view.layer.removeAnimation(forKey: "pulse-highlight")
        }
    }
    
    private func populateMatrix() {
        // 两种模式都使用 5x6 布局，显示所有 27 张麻将
        let matrixCols = 6
        let matrixRows = 5
        let totalTiles = matrixCols * matrixRows
        
        // 获取所有三种类型的麻将并打乱
        let glyphs = HeptagramLedger.shared.mixedSuite(count: totalTiles)
        
        let padding: CGFloat = 16
        let spacing: CGFloat = 10
        let availableWidth = lowerMatrix.bounds.width - padding * 2
        let tileWidth = (availableWidth - CGFloat(matrixCols - 1) * spacing) / CGFloat(matrixCols)
        let tileHeight = tileWidth * 1.385
        
        for row in 0..<matrixRows {
            for col in 0..<matrixCols {
                let index = row * matrixCols + col
                guard index < glyphs.count else { continue }
                let glyph = glyphs[index]
                let tileView = KaleidoTileView(glyph: glyph)
                let originX = padding + CGFloat(col) * (tileWidth + spacing)
                let originY = padding + CGFloat(row) * (tileHeight + spacing)
                tileView.frame = CGRect(x: originX, y: originY, width: tileWidth, height: tileHeight)
                let tap = UITapGestureRecognizer(target: self, action: #selector(handleTileSelection(_:)))
                tileView.addGestureRecognizer(tap)
                lowerMatrix.addSubview(tileView)
                matrixTiles.append(tileView)
            }
        }
    }
    
    private func animateRunway() {
        view.layoutIfNeeded()
        let travelDistance = upperRunway.bounds.width + (glyphTrack.last?.frame.maxX ?? 0)
        
        // 第一种模式（uniform）使用更慢的速度：18秒，第二种模式保持12秒
        let duration: TimeInterval = mode == .uniform ? 18.0 : 12.0
        
        animator?.stopAnimation(true)
        animator = UIViewPropertyAnimator(duration: duration, curve: .linear)
        animator?.addAnimations { [weak self] in
            guard let self = self else { return }
            for slot in self.glyphTrack {
                slot.frame.origin.x -= travelDistance
            }
        }
        animator?.addCompletion { [weak self] position in
            guard let self = self else { return }
            if position == .end && !self.pendingValues.isEmpty {
                self.handleMiss()
            }
        }
        animator?.startAnimation()
    }
    
    @objc private func handleTileSelection(_ gesture: UITapGestureRecognizer) {
        guard let tile = gesture.view as? KaleidoTileView,
              let expected = pendingValues.first else {
            return
        }
        
        
        tile.igniteSelection()
        if tile.glyph.numericValue == expected {
            showCorrectFeedback()
            resolveCorrect(tile: tile)
        } else {
            showWrongFeedback()
            lives -= 1
            updateBadges()
            if lives <= 0 { endGame() }
        }
    }
    
    private func resolveCorrect(tile: KaleidoTileView) {
   
        
        // 找到对应的空格索引（应该填充的第一个空格）
        guard let expectedValue = pendingValues.first,
              let gapIndexInOrder = gapOrder.firstIndex(of: expectedValue) else {
            tile.removeFromSuperview()
            return
        }
        
        
        guard gapIndexInOrder < gapViews.count else {
            tile.removeFromSuperview()
            return
        }
        
        let gapView = gapViews[gapIndexInOrder]
     
        
        // 移除所有子视图和动画
        gapView.layer.removeAllAnimations()
        gapView.subviews.forEach { 
            $0.removeFromSuperview()
        }
        
   
        gapView.layoutIfNeeded()
        
        // 创建麻将视图并添加到空格中
        let candidate = KaleidoTileView(glyph: tile.glyph)
        candidate.autoresizingMask = [.flexibleWidth, .flexibleHeight]  // 自动调整大小
        candidate.frame = CGRect(x: 0, y: 0, width: gapView.bounds.width, height: gapView.bounds.height)
        candidate.isUserInteractionEnabled = false
        candidate.clipsToBounds = true
        gapView.addSubview(candidate)
        
        // 清除空格的虚线边框样式
        gapView.layer.borderColor = UIColor.clear.cgColor
        gapView.layer.borderWidth = 0
        gapView.backgroundColor = .clear
        
        // 强制立即布局更新
        candidate.layoutIfNeeded()
        gapView.setNeedsLayout()
        gapView.layoutIfNeeded()
        
    
        
        // 验证麻将确实在视图层级中
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if let first = gapView.subviews.first {
            }
        }
        
        // 移除下方的原始麻将
        tile.removeFromSuperview()
        if let index = self.matrixTiles.firstIndex(of: tile) {
            self.matrixTiles.remove(at: index)
        }
        
        // 移除已完成的值
        self.pendingValues.removeFirst()
        
        // 更新分数
        self.score += 15
        self.updateBadges()
        
        // 检查是否完成所有空格
        if self.pendingValues.isEmpty {
            self.animator?.stopAnimation(true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
                self?.beginNewRound()
            }
        }
    }
    
    private func handleMiss() {
        lives -= 1
        updateBadges()
        if lives <= 0 {
            endGame()
        } else {
            beginNewRound()
        }
    }
    
    private func updateBadges() {
        scoreBadge.text = "Score: \(score)"
        lifeBadge.text = String(repeating: "♥︎", count: max(lives, 0))
        roundBadge.text = "Round \(roundIndex)"
    }
    
    /// 显示选择正确的反馈动画
    private func showCorrectFeedback() {
        let feedbackView = createFeedbackView(
            icon: "checkmark.circle.fill",
            text: "Correct!",
            color: .systemGreen
        )
        animateFeedback(feedbackView)
    }
    
    /// 显示选择错误的反馈动画
    private func showWrongFeedback() {
        let feedbackView = createFeedbackView(
            icon: "xmark.circle.fill",
            text: "Wrong!",
            color: .systemRed
        )
        animateFeedback(feedbackView)
    }
    
    /// 创建反馈视图
    private func createFeedbackView(icon: String, text: String, color: UIColor) -> UIView {
        let container = UIView()
        container.backgroundColor = color.withAlphaComponent(0.95)
        container.layer.cornerRadius = 25
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOffset = CGSize(width: 0, height: 4)
        container.layer.shadowRadius = 10
        container.layer.shadowOpacity = 0.5
        
        let iconConfig = UIImage.SymbolConfiguration(pointSize: 40, weight: .bold)
        let iconView = UIImageView(image: UIImage(systemName: icon, withConfiguration: iconConfig))
        iconView.tintColor = .white
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(iconView)
        container.addSubview(label)
        
        NSLayoutConstraint.activate([
            iconView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            iconView.topAnchor.constraint(equalTo: container.topAnchor, constant: 20),
            iconView.widthAnchor.constraint(equalToConstant: 50),
            iconView.heightAnchor.constraint(equalToConstant: 50),
            
            label.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            label.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 12),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -20)
        ])
        
        return container
    }
    
    /// 执行反馈动画
    private func animateFeedback(_ feedbackView: UIView) {
        feedbackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(feedbackView)
        
        NSLayoutConstraint.activate([
            feedbackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            feedbackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            feedbackView.widthAnchor.constraint(equalToConstant: 200),
            feedbackView.heightAnchor.constraint(equalToConstant: 150)
        ])
        
        // 初始状态
        feedbackView.alpha = 0
        feedbackView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        
        // 动画序列
        UIView.animateKeyframes(withDuration: 0.8, delay: 0, options: [], animations: {
            // 弹出
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.3) {
                feedbackView.alpha = 1
                feedbackView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            }
            
            // 回弹
            UIView.addKeyframe(withRelativeStartTime: 0.3, relativeDuration: 0.2) {
                feedbackView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }
            
            // 停留
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.2) {
                // 保持显示
            }
            
            // 消失
            UIView.addKeyframe(withRelativeStartTime: 0.7, relativeDuration: 0.3) {
                feedbackView.alpha = 0
                feedbackView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            }
        }) { _ in
            feedbackView.removeFromSuperview()
        }
    }
    
    private func endGame() {
        animator?.stopAnimation(true)
        let elapsed = Int(Date().timeIntervalSince(startDate))
        let record = VoyageRegister(score: score, duration: elapsed, mode: mode.rawValue)
        ChronicleArchivist.shared.save(record: record)
        let alert = UIAlertController(title: "Voyage Complete", message: "Score \(score)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Again", style: .default) { _ in
            self.score = 0
            self.lives = 5
            self.roundIndex = 0
            self.startDate = Date()
            self.beginNewRound()
        })
        alert.addAction(UIAlertAction(title: "Exit", style: .destructive) { _ in
            self.dismiss(animated: true)
        })
        present(alert, animated: true)
    }
    
    @objc private func quitGame() {
        dismiss(animated: true)
    }
    
    override var prefersStatusBarHidden: Bool { true }
}


