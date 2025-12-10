//
//  GameplayOrchestrationViewController.swift
//  GapRunner
//
//  Created by Zhao on 2025/11/28.
//

import UIKit

class GameplayOrchestrationViewController: UIViewController {
    
    let gameMode: GameplayMode
    
    // UI Components
    let returnButton = NavigationReturnButton()
    let scoreLabel = UILabel()
    let livesLabel = UILabel()
    let progressLabel = UILabel()
    
    let upperTrackContainer = UIView()
    let lowerSelectionContainer = UIView()
    
    var upperTileViews: [UIView] = []
    var gapViews: [UIView] = []  // Track gap views separately
    var lowerTileViews: [TileImageViewComponent] = []
    
    // Game State
    var currentScore = 0
    var remainingLives = 5
    var completedRounds = 0
    var gapPositions: [Int] = []
    var expectedAnswers: [Int] = []
    var currentCatalogue: TileCatalogue = .bamboo
    var gameTimer: Timer?
    var startTimestamp: Date?
    var trackAnimator: UIViewPropertyAnimator?
    var currentGapIndex = 0  // Track which gap should be filled next
    
    // Constants
    let tileAspectRatio: CGFloat = 1.0 / 1.385
    
    /// 动画持续时间 - 第一种模式（uniform）使用18秒，第二种模式使用12秒
    var trackMovementDuration: TimeInterval {
        return gameMode == .uniform ? 18.0 : 12.0
    }
    
    init(gameMode: GameplayMode) {
        self.gameMode = gameMode
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var hasStartedGame = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        installBackgroundImagery()
        assembleInterface()
        configureConstraints()
        startTimestamp = Date()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !hasStartedGame else { return }
        hasStartedGame = true
        initiateNewRound()
    }
    
    deinit {
        trackAnimator?.stopAnimation(true)
        gameTimer?.invalidate()
    }
}

// MARK: - UI Setup
extension GameplayOrchestrationViewController {
    
    func assembleInterface() {
        returnButton.addTarget(self, action: #selector(dismissWithConfirmation), for: .touchUpInside)
        view.addSubview(returnButton)
        
        scoreLabel.font = UIFont.boldSystemFont(ofSize: 20)
        scoreLabel.textColor = .white
        scoreLabel.textAlignment = .center
        scoreLabel.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.7)
        scoreLabel.layer.cornerRadius = 12
        scoreLabel.layer.masksToBounds = true
        scoreLabel.layer.borderWidth = 2
        scoreLabel.layer.borderColor = UIColor.white.withAlphaComponent(0.4).cgColor
        updateScoreDisplay()
        view.addSubview(scoreLabel)
        
        livesLabel.font = UIFont.boldSystemFont(ofSize: 20)
        livesLabel.textColor = .white
        livesLabel.textAlignment = .center
        livesLabel.backgroundColor = UIColor.systemPink.withAlphaComponent(0.7)
        livesLabel.layer.cornerRadius = 12
        livesLabel.layer.masksToBounds = true
        livesLabel.layer.borderWidth = 2
        livesLabel.layer.borderColor = UIColor.white.withAlphaComponent(0.4).cgColor
        updateLivesDisplay()
        view.addSubview(livesLabel)
        
        progressLabel.font = UIFont.boldSystemFont(ofSize: 18)
        progressLabel.textColor = .white
        progressLabel.textAlignment = .center
        progressLabel.backgroundColor = UIColor.systemPurple.withAlphaComponent(0.7)
        progressLabel.layer.cornerRadius = 12
        progressLabel.layer.masksToBounds = true
        progressLabel.layer.borderWidth = 2
        progressLabel.layer.borderColor = UIColor.white.withAlphaComponent(0.4).cgColor
        view.addSubview(progressLabel)
        
        upperTrackContainer.backgroundColor = .clear
        view.addSubview(upperTrackContainer)
        
        lowerSelectionContainer.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        lowerSelectionContainer.layer.cornerRadius = 16
        view.addSubview(lowerSelectionContainer)
    }
    
    func configureConstraints() {
        returnButton.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        livesLabel.translatesAutoresizingMaskIntoConstraints = false
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        upperTrackContainer.translatesAutoresizingMaskIntoConstraints = false
        lowerSelectionContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let isPad = UIDevice.current.userInterfaceIdiom == .pad
        let sideMargin: CGFloat = isPad ? 60 : 20
        let containerHeight: CGFloat = isPad ? 140 : 100
        let lowerHeight: CGFloat = isPad ? 450 : 320
        
        NSLayoutConstraint.activate([
            returnButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),
            returnButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: sideMargin),
            returnButton.widthAnchor.constraint(equalToConstant: 40),
            returnButton.heightAnchor.constraint(equalToConstant: 40),
            
            scoreLabel.leadingAnchor.constraint(equalTo: returnButton.trailingAnchor, constant: 16),
            scoreLabel.centerYAnchor.constraint(equalTo: returnButton.centerYAnchor),
            scoreLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 100),
            scoreLabel.heightAnchor.constraint(equalToConstant: 40),
            
            livesLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -sideMargin),
            livesLabel.centerYAnchor.constraint(equalTo: returnButton.centerYAnchor),
            livesLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 100),
            livesLabel.heightAnchor.constraint(equalToConstant: 40),
            
            progressLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            progressLabel.topAnchor.constraint(equalTo: returnButton.bottomAnchor, constant: 12),
            progressLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 120),
            progressLabel.heightAnchor.constraint(equalToConstant: 36),
            
            upperTrackContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            upperTrackContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            upperTrackContainer.topAnchor.constraint(equalTo: progressLabel.bottomAnchor, constant: 20),
            upperTrackContainer.heightAnchor.constraint(equalToConstant: containerHeight),
            
            lowerSelectionContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: sideMargin),
            lowerSelectionContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -sideMargin),
            lowerSelectionContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            lowerSelectionContainer.heightAnchor.constraint(equalToConstant: lowerHeight)
        ])
    }
}

// MARK: - Game Logic
extension GameplayOrchestrationViewController {
    
    func initiateNewRound() {
        
        // Increment round counter first
        completedRounds += 1
        updateProgressDisplay()
        
        // Clear previous round
        upperTileViews.forEach { $0.removeFromSuperview() }
        upperTileViews.removeAll()
        gapViews.removeAll()
        lowerTileViews.forEach { $0.removeFromSuperview() }
        lowerTileViews.removeAll()
        currentGapIndex = 0
        
        // Generate new sequence
        generateUpperSequence()
        populateLowerSelection()
        
        // Force layout update before starting animation
        upperTrackContainer.layoutIfNeeded()
        view.layoutIfNeeded()
        
        animateUpperTrack()
        highlightCurrentGap()
    }
    
    func generateUpperSequence() {
        let sequenceLength = Int.random(in: 3...7)
        let gapCount = Int.random(in: 1...(sequenceLength - 1))
        
        // Select category
        currentCatalogue = gameMode == .uniform ? 
            TileRepertoire.shared.retrieveRandomCategory() : .bamboo
        
        // Generate sequence with gaps - 确保不连续超过2个空格
        let startValue = Int.random(in: 1...(9 - sequenceLength + 1))
        var selectedGapPositions: [Int] = []
        var availablePositions = Array(0..<sequenceLength)
        
        for _ in 0..<gapCount {
            // 过滤掉会导致连续超过2个空格的位置
            let validPositions = availablePositions.filter { pos in
                let testPositions = (selectedGapPositions + [pos]).sorted()
                return !hasMoreThanTwoConsecutiveGaps(testPositions)
            }
            
            if let selectedPos = validPositions.randomElement() {
                selectedGapPositions.append(selectedPos)
                availablePositions.removeAll { $0 == selectedPos }
            }
        }
        
        gapPositions = selectedGapPositions.sorted()
        expectedAnswers = gapPositions.map { startValue + $0 }
        
        // Create tile views
        let isPad = UIDevice.current.userInterfaceIdiom == .pad
        let tileHeight: CGFloat = isPad ? 120 : 80
        let tileWidth = tileHeight * tileAspectRatio
        let spacing: CGFloat = isPad ? 20 : 12
        let totalWidth = CGFloat(sequenceLength) * tileWidth + CGFloat(sequenceLength - 1) * spacing
        var xOffset = view.bounds.width
        
        for i in 0..<sequenceLength {
            let tileValue = startValue + i
            let isGap = gapPositions.contains(i)
            
            let tileView = UIView()
            tileView.frame = CGRect(x: xOffset, y: (upperTrackContainer.bounds.height - tileHeight) / 2, 
                                    width: tileWidth, height: tileHeight)
            tileView.tag = tileValue  // Store the expected value as tag
            
            if isGap {
                tileView.backgroundColor = UIColor.white.withAlphaComponent(0.3)
                tileView.layer.cornerRadius = 6
                
                // Add dashed border
                let dashedBorder = CAShapeLayer()
                dashedBorder.name = "dashedBorder"
                dashedBorder.strokeColor = UIColor.white.withAlphaComponent(0.6).cgColor
                dashedBorder.lineDashPattern = [6, 3]
                dashedBorder.frame = CGRect(x: 0, y: 0, width: tileWidth, height: tileHeight)
                dashedBorder.fillColor = nil
                dashedBorder.path = UIBezierPath(roundedRect: dashedBorder.frame, cornerRadius: 6).cgPath
                dashedBorder.lineWidth = 2
                tileView.layer.addSublayer(dashedBorder)
                
                // Store gap views for later reference
                gapViews.append(tileView)
            } else {
                let category = gameMode == .uniform ? currentCatalogue : 
                    TileCatalogue.allCases.randomElement()!
                let tiles = TileRepertoire.shared.retrieveCollection(for: category)
                if let tile = tiles.first(where: { $0.numericalValue == tileValue }) {
                    let imageView = TileImageViewComponent(tile: tile)
                    imageView.frame = tileView.bounds
                    imageView.isUserInteractionEnabled = false
                    tileView.addSubview(imageView)
                }
            }
            
            upperTrackContainer.addSubview(tileView)
            upperTileViews.append(tileView)
            xOffset += tileWidth + spacing
        }
    }
    
    /// 检查位置数组中是否有连续超过2个的情况
    func hasMoreThanTwoConsecutiveGaps(_ positions: [Int]) -> Bool {
        guard positions.count >= 3 else { return false }
        let sorted = positions.sorted()
        for i in 0..<(sorted.count - 2) {
            if sorted[i+1] == sorted[i] + 1 && sorted[i+2] == sorted[i] + 2 {
                return true
            }
        }
        return false
    }
    
    func populateLowerSelection() {
        let isPad = UIDevice.current.userInterfaceIdiom == .pad
        let padding: CGFloat = isPad ? 30 : 20
        let spacing: CGFloat = isPad ? 15 : 10
        
        // 两种模式都使用 5x6 网格，显示所有 27 张麻将
        let rows = 5
        let cols = 6
        let allTiles = TileRepertoire.shared.retrieveAllTiles().shuffled()
        
        let availableWidth = lowerSelectionContainer.bounds.width - 2 * padding
        let availableHeight = lowerSelectionContainer.bounds.height - 2 * padding
        let maxTileWidth = (availableWidth - CGFloat(cols - 1) * spacing) / CGFloat(cols)
        let maxTileHeight = (availableHeight - CGFloat(rows - 1) * spacing) / CGFloat(rows)
        
        // Calculate actual tile size based on aspect ratio
        let tileHeight = min(maxTileWidth / tileAspectRatio, maxTileHeight)
        let finalTileWidth = tileHeight * tileAspectRatio
        
        // Calculate total grid size
        let totalGridWidth = CGFloat(cols) * finalTileWidth + CGFloat(cols - 1) * spacing
        let totalGridHeight = CGFloat(rows) * tileHeight + CGFloat(rows - 1) * spacing
        
        // Calculate starting position to center the grid
        let startX = (lowerSelectionContainer.bounds.width - totalGridWidth) / 2
        let startY = (lowerSelectionContainer.bounds.height - totalGridHeight) / 2
        
        for row in 0..<rows {
            for col in 0..<cols {
                let index = row * cols + col
                if index < allTiles.count {
                    let tile = allTiles[index]
                    let tileView = TileImageViewComponent(tile: tile)
                    
                    let x = startX + CGFloat(col) * (finalTileWidth + spacing)
                    let y = startY + CGFloat(row) * (tileHeight + spacing)
                    tileView.frame = CGRect(x: x, y: y, width: finalTileWidth, height: tileHeight)
                    
                    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTileSelection(_:)))
                    tileView.addGestureRecognizer(tapGesture)
                    
                    lowerSelectionContainer.addSubview(tileView)
                    lowerTileViews.append(tileView)
                }
            }
        }
    }
    
    func animateUpperTrack() {
        // Safely stop and clear any existing animator WITHOUT triggering completion
        if let existingAnimator = trackAnimator {
            if existingAnimator.state == .active || existingAnimator.isRunning {
                existingAnimator.stopAnimation(true)
                // Don't call finishAnimation to avoid triggering completion handler
            }
        }
        trackAnimator = nil
        
        // Calculate the total distance to move (from right edge to left edge plus all tiles width)
        guard let firstTile = upperTileViews.first, let lastTile = upperTileViews.last else {
            return
        }
        let totalMovementDistance = firstTile.frame.origin.x + lastTile.frame.width + lastTile.frame.origin.x - firstTile.frame.origin.x
        
        // Create animator without animations first
        trackAnimator = UIViewPropertyAnimator(duration: trackMovementDuration, curve: .linear)
        
        // Add animations separately (this prevents immediate execution)
        trackAnimator?.addAnimations { [weak self] in
            guard let self = self else {
                return
            }
            // Move all tiles by the same distance to keep spacing consistent
            for (index, tileView) in self.upperTileViews.enumerated() {
                let oldX = tileView.frame.origin.x
                tileView.frame.origin.x -= totalMovementDistance
                if index == 0 {
                }
            }
        }
        
        trackAnimator?.addCompletion { [weak self] position in
            guard let self = self else {
                return
            }
            
            // Only handle .end position (natural completion)
            if position == .end {
                if !self.expectedAnswers.isEmpty {
                    self.handleMissedSequence()
                } else {
                }
            } else {
            }
        }
        
        trackAnimator?.startAnimation()
    }
    
    @objc func handleTileSelection(_ gesture: UITapGestureRecognizer) {
        guard let tileView = gesture.view as? TileImageViewComponent else { return }
        
        let selectedValue = tileView.tileEntity.numericalValue
        
        if let firstExpected = expectedAnswers.first, firstExpected == selectedValue {
            
            // Correct answer - 直接填充空格
            guard currentGapIndex < gapViews.count else {
                return
            }
            let targetGap = gapViews[currentGapIndex]
            
           
            
            // 显示正确反馈
            showCorrectFeedback()
            
            // 直接填充空格（无动画）
            fillGap(targetGap, with: tileView.tileEntity)
            
            // Remove the tile from lower selection
            tileView.removeFromSuperview()
            if let index = self.lowerTileViews.firstIndex(of: tileView) {
                self.lowerTileViews.remove(at: index)
            }
            
            // Update game state
            self.expectedAnswers.removeFirst()
            self.currentGapIndex += 1
            
            self.currentScore += 10
            self.updateScoreDisplay()
            
            if self.expectedAnswers.isEmpty {
                // All gaps filled - complete round
                // Check if animator is running before stopping it
                if self.trackAnimator?.isRunning == true {
                    self.trackAnimator?.stopAnimation(false)
                    self.trackAnimator?.finishAnimation(at: .current)
                }
                
                // Show round complete animation
                self.showRoundCompleteAnimation()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.initiateNewRound()
                }
            } else {
                // Highlight next gap
                self.highlightCurrentGap()
            }
        } else {
            // Wrong answer - 显示错误反馈
            showWrongFeedback()
            tileView.animateIncorrectShake()
            remainingLives -= 1
            updateLivesDisplay()
            
            if remainingLives <= 0 {
                concludeGame()
            }
        }
    }
    
    func fillGap(_ gapView: UIView, with tile: MahjongTileEntity) {
        
        // Remove dashed border
        gapView.layer.sublayers?.first(where: { $0.name == "dashedBorder" })?.removeFromSuperlayer()
        
        // Change background
        gapView.backgroundColor = .clear
        
        // 移除所有现有子视图
        gapView.subviews.forEach { $0.removeFromSuperview() }
        
        // 确保bounds正确
        gapView.layoutIfNeeded()
        
        // Add tile image
        let imageView = TileImageViewComponent(tile: tile)
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]  // 自动调整大小
        imageView.frame = CGRect(x: 0, y: 0, width: gapView.bounds.width, height: gapView.bounds.height)
        imageView.isUserInteractionEnabled = false
        imageView.clipsToBounds = true
        gapView.addSubview(imageView)
        
        // 强制立即布局更新
        imageView.layoutIfNeeded()
        gapView.setNeedsLayout()
        gapView.layoutIfNeeded()
        
      
        
        // 验证麻将确实在视图层级中
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if let first = gapView.subviews.first {
            }
        }
        
        // Show score animation
        showScoreAnimation(at: gapView, points: 10)
    }
    
    func showScoreAnimation(at view: UIView, points: Int) {
        // Create score label
        let scoreLabel = UILabel()
        scoreLabel.text = "+\(points)"
        scoreLabel.font = UIFont.boldSystemFont(ofSize: 32)
        scoreLabel.textColor = .systemYellow
        scoreLabel.textAlignment = .center
        scoreLabel.layer.shadowColor = UIColor.black.cgColor
        scoreLabel.layer.shadowOffset = CGSize(width: 0, height: 2)
        scoreLabel.layer.shadowRadius = 4
        scoreLabel.layer.shadowOpacity = 0.8
        
        // Position it at the gap location in view coordinates
        let gapFrameInView = self.view.convert(view.frame, from: view.superview)
        scoreLabel.frame = CGRect(x: gapFrameInView.midX - 50, 
                                  y: gapFrameInView.midY - 20, 
                                  width: 100, 
                                  height: 40)
        
        self.view.addSubview(scoreLabel)
        
        // Animate: float up and fade out
        UIView.animateKeyframes(withDuration: 1.2, delay: 0, options: [], animations: {
            // Phase 1: Pop in with scale
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.2) {
                scoreLabel.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            }
            
            // Phase 2: Float up
            UIView.addKeyframe(withRelativeStartTime: 0.2, relativeDuration: 0.8) {
                scoreLabel.frame.origin.y -= 60
                scoreLabel.alpha = 0
                scoreLabel.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }
        }) { _ in
            scoreLabel.removeFromSuperview()
        }
        
        // Add particle effect
        addScoreParticles(at: gapFrameInView)
    }
    
    func addScoreParticles(at frame: CGRect) {
        let particleCount = 8
        
        for i in 0..<particleCount {
            let particle = UIView()
            particle.backgroundColor = .systemYellow
            particle.layer.cornerRadius = 3
            let size: CGFloat = CGFloat.random(in: 4...8)
            particle.frame = CGRect(x: frame.midX, y: frame.midY, width: size, height: size)
            view.addSubview(particle)
            
            // Random direction
            let angle = (CGFloat(i) / CGFloat(particleCount)) * 2 * .pi
            let distance: CGFloat = CGFloat.random(in: 30...60)
            let targetX = frame.midX + cos(angle) * distance
            let targetY = frame.midY + sin(angle) * distance
            
            UIView.animate(withDuration: 0.6, delay: 0, options: .curveEaseOut, animations: {
                particle.frame.origin.x = targetX
                particle.frame.origin.y = targetY
                particle.alpha = 0
                particle.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            }) { _ in
                particle.removeFromSuperview()
            }
        }
    }
    
    func highlightCurrentGap() {
        // Remove highlight from all gaps
        for (index, gapView) in gapViews.enumerated() {
            if let dashedLayer = gapView.layer.sublayers?.first(where: { $0.name == "dashedBorder" }) as? CAShapeLayer {
                if index == currentGapIndex {
                    // Highlight current gap
                    dashedLayer.strokeColor = UIColor.systemYellow.cgColor
                    dashedLayer.lineWidth = 3
                    gapView.backgroundColor = UIColor.systemYellow.withAlphaComponent(0.2)
                    
                    // Add pulsing animation
                    let pulseAnimation = CABasicAnimation(keyPath: "opacity")
                    pulseAnimation.fromValue = 1.0
                    pulseAnimation.toValue = 0.5
                    pulseAnimation.duration = 0.8
                    pulseAnimation.autoreverses = true
                    pulseAnimation.repeatCount = .infinity
                    dashedLayer.add(pulseAnimation, forKey: "pulse")
                } else {
                    // Reset other gaps to default
                    dashedLayer.strokeColor = UIColor.white.withAlphaComponent(0.6).cgColor
                    dashedLayer.lineWidth = 2
                    gapView.backgroundColor = UIColor.white.withAlphaComponent(0.3)
                    dashedLayer.removeAnimation(forKey: "pulse")
                }
            }
        }
    }
    
    func showRoundCompleteAnimation() {
        // Create "Round Complete!" label
        let completeLabel = UILabel()
        completeLabel.text = "Round Complete!"
        completeLabel.font = UIFont.boldSystemFont(ofSize: 40)
        completeLabel.textColor = .white
        completeLabel.textAlignment = .center
        completeLabel.layer.shadowColor = UIColor.black.cgColor
        completeLabel.layer.shadowOffset = CGSize(width: 0, height: 3)
        completeLabel.layer.shadowRadius = 6
        completeLabel.layer.shadowOpacity = 0.8
        
        completeLabel.frame = CGRect(x: 0, y: view.bounds.midY - 30, width: view.bounds.width, height: 60)
        completeLabel.alpha = 0
        completeLabel.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        view.addSubview(completeLabel)
        
        // Animate label
        UIView.animateKeyframes(withDuration: 1.5, delay: 0, options: [], animations: {
            // Pop in
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.3) {
                completeLabel.alpha = 1
                completeLabel.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            }
            
            // Settle
            UIView.addKeyframe(withRelativeStartTime: 0.3, relativeDuration: 0.2) {
                completeLabel.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }
            
            // Fade out
            UIView.addKeyframe(withRelativeStartTime: 0.7, relativeDuration: 0.3) {
                completeLabel.alpha = 0
                completeLabel.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            }
        }) { _ in
            completeLabel.removeFromSuperview()
        }
        
        // Add celebration particles
        addCelebrationParticles()
    }
    
    func addCelebrationParticles() {
        let particleCount = 30
        let colors: [UIColor] = [.systemYellow, .systemOrange, .systemGreen, .systemBlue, .systemPurple]
        
        for i in 0..<particleCount {
            let particle = UIView()
            particle.backgroundColor = colors.randomElement()
            particle.layer.cornerRadius = 5
            let size: CGFloat = CGFloat.random(in: 6...12)
            
            // Start from center
            let startX = view.bounds.midX
            let startY = view.bounds.midY
            particle.frame = CGRect(x: startX, y: startY, width: size, height: size)
            view.addSubview(particle)
            
            // Random explosion direction
            let angle = (CGFloat(i) / CGFloat(particleCount)) * 2 * .pi + CGFloat.random(in: -0.2...0.2)
            let distance: CGFloat = CGFloat.random(in: 100...200)
            let targetX = startX + cos(angle) * distance
            let targetY = startY + sin(angle) * distance
            
            let duration = Double.random(in: 0.8...1.2)
            
            UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: {
                particle.frame.origin.x = targetX
                particle.frame.origin.y = targetY
                particle.alpha = 0
                particle.transform = CGAffineTransform(rotationAngle: .pi * 2)
            }) { _ in
                particle.removeFromSuperview()
            }
        }
    }
    
    func handleMissedSequence() {
        remainingLives -= 1
        updateLivesDisplay()
        
        if remainingLives <= 0 {
            concludeGame()
        } else {
            initiateNewRound()
        }
    }
    
    func concludeGame() {
        // Safely stop animator if it's running
        if trackAnimator?.isRunning == true {
            trackAnimator?.stopAnimation(true)
        }
        
        let duration = Int(Date().timeIntervalSince(startTimestamp ?? Date()))
        let record = GameAchievementRecord(score: currentScore, mode: gameMode, duration: duration)
        PersistenceCoordinator.shared.archiveRecord(record)
        
        presentGameOverAlert()
    }
    
    func presentGameOverAlert() {
        let alert = UIAlertController(title: "Game Over", 
                                       message: "Final Score: \(currentScore)\nRounds: \(completedRounds)", 
                                       preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Play Again", style: .default) { [weak self] _ in
            self?.resetGame()
        })
        alert.addAction(UIAlertAction(title: "Main Menu", style: .cancel) { [weak self] _ in
            self?.dismiss(animated: true)
        })
        present(alert, animated: true)
    }
    
    func resetGame() {
        currentScore = 0
        remainingLives = 5
        completedRounds = 0
        currentGapIndex = 0
        startTimestamp = Date()
        updateScoreDisplay()
        updateLivesDisplay()
        initiateNewRound()
    }
}

// MARK: - UI Updates
extension GameplayOrchestrationViewController {
    
    func updateScoreDisplay() {
        scoreLabel.text = "Score: \(currentScore)"
    }
    
    func updateLivesDisplay() {
        let hearts = String(repeating: "❤️", count: remainingLives)
        livesLabel.text = hearts.isEmpty ? "💔" : hearts
    }
    
    func updateProgressDisplay() {
        progressLabel.text = "Round \(completedRounds)"
    }
    
    /// 显示选择正确的反馈动画
    func showCorrectFeedback() {
        let feedbackView = createFeedbackView(
            icon: "checkmark.circle.fill",
            text: "Correct!",
            color: .systemGreen
        )
        animateFeedback(feedbackView)
    }
    
    /// 显示选择错误的反馈动画
    func showWrongFeedback() {
        let feedbackView = createFeedbackView(
            icon: "xmark.circle.fill",
            text: "Wrong!",
            color: .systemRed
        )
        animateFeedback(feedbackView)
    }
    
    /// 创建反馈视图
    func createFeedbackView(icon: String, text: String, color: UIColor) -> UIView {
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
    func animateFeedback(_ feedbackView: UIView) {
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
    
    @objc func dismissWithConfirmation() {
        let alert = UIAlertController(title: "Quit Game?", 
                                       message: "Your progress will be lost", 
                                       preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Continue Playing", style: .cancel))
        alert.addAction(UIAlertAction(title: "Quit", style: .destructive) { [weak self] _ in
            if self?.trackAnimator?.isRunning == true {
                self?.trackAnimator?.stopAnimation(true)
            }
            self?.dismiss(animated: true)
        })
        present(alert, animated: true)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

