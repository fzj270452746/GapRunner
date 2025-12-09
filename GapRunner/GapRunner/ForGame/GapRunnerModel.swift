//
//  GapRunnerModel.swift
//  GapRunner
//
//  Created by Zhao on 2025/11/28.
//

import UIKit

// MARK: - Tile Categories
enum TileCatalogue: String, CaseIterable {
    case bamboo = "pict"
    case character = "picU"
    case dot = "picV"
    
    var displayName: String {
        switch self {
        case .bamboo: return "Bamboo"
        case .character: return "Character"
        case .dot: return "Dot"
        }
    }
}

// MARK: - Mahjong Tile Model
struct MahjongTileEntity {
    let tileImage: UIImage
    let numericalValue: Int
    let catalogue: TileCatalogue
    
    init(imageName: String, value: Int, category: TileCatalogue) {
        self.tileImage = UIImage(named: imageName) ?? UIImage()
        self.numericalValue = value
        self.catalogue = category
    }
}

// MARK: - Game Mode
enum GameplayMode {
    case uniform      // Mode 1: Same category tiles
    case diverse      // Mode 2: Mixed category tiles
}

// MARK: - Game Record Model
struct GameAchievementRecord: Codable {
    let recordIdentifier: String
    let scoreObtained: Int
    let gameModeType: String
    let timestamp: Date
    let durationInSeconds: Int
    
    init(score: Int, mode: GameplayMode, duration: Int) {
        self.recordIdentifier = UUID().uuidString
        self.scoreObtained = score
        self.gameModeType = mode == .uniform ? "Uniform Mode" : "Diverse Mode"
        self.timestamp = Date()
        self.durationInSeconds = duration
    }
}

// MARK: - Tile Collections
class TileRepertoire {
    
    static let shared = TileRepertoire()
    
    let bambooCollection: [MahjongTileEntity] = [
        MahjongTileEntity(imageName: "pict 1", value: 1, category: .bamboo),
        MahjongTileEntity(imageName: "pict 2", value: 2, category: .bamboo),
        MahjongTileEntity(imageName: "pict 3", value: 3, category: .bamboo),
        MahjongTileEntity(imageName: "pict 4", value: 4, category: .bamboo),
        MahjongTileEntity(imageName: "pict 5", value: 5, category: .bamboo),
        MahjongTileEntity(imageName: "pict 6", value: 6, category: .bamboo),
        MahjongTileEntity(imageName: "pict 7", value: 7, category: .bamboo),
        MahjongTileEntity(imageName: "pict 8", value: 8, category: .bamboo),
        MahjongTileEntity(imageName: "pict 9", value: 9, category: .bamboo)
    ]
    
    let characterCollection: [MahjongTileEntity] = [
        MahjongTileEntity(imageName: "picU 1", value: 1, category: .character),
        MahjongTileEntity(imageName: "picU 2", value: 2, category: .character),
        MahjongTileEntity(imageName: "picU 3", value: 3, category: .character),
        MahjongTileEntity(imageName: "picU 4", value: 4, category: .character),
        MahjongTileEntity(imageName: "picU 5", value: 5, category: .character),
        MahjongTileEntity(imageName: "picU 6", value: 6, category: .character),
        MahjongTileEntity(imageName: "picU 7", value: 7, category: .character),
        MahjongTileEntity(imageName: "picU 8", value: 8, category: .character),
        MahjongTileEntity(imageName: "picU 9", value: 9, category: .character)
    ]
    
    let dotCollection: [MahjongTileEntity] = [
        MahjongTileEntity(imageName: "picV 1", value: 1, category: .dot),
        MahjongTileEntity(imageName: "picV 2", value: 2, category: .dot),
        MahjongTileEntity(imageName: "picV 3", value: 3, category: .dot),
        MahjongTileEntity(imageName: "picV 4", value: 4, category: .dot),
        MahjongTileEntity(imageName: "picV 5", value: 5, category: .dot),
        MahjongTileEntity(imageName: "picV 6", value: 6, category: .dot),
        MahjongTileEntity(imageName: "picV 7", value: 7, category: .dot),
        MahjongTileEntity(imageName: "picV 8", value: 8, category: .dot),
        MahjongTileEntity(imageName: "picV 9", value: 9, category: .dot)
    ]
    
    func retrieveCollection(for category: TileCatalogue) -> [MahjongTileEntity] {
        switch category {
        case .bamboo: return bambooCollection
        case .character: return characterCollection
        case .dot: return dotCollection
        }
    }
    
    func retrieveAllTiles() -> [MahjongTileEntity] {
        return bambooCollection + characterCollection + dotCollection
    }
    
    func retrieveRandomCategory() -> TileCatalogue {
        return TileCatalogue.allCases.randomElement() ?? .bamboo
    }
}