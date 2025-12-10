//
//  HeptagramLedger.swift
//  GapRunner
//
//  Created by Zhao on 2025/12/10.
//

import UIKit

// MARK: - Tile Taxonomy
enum MosaicGlyphFamily: CaseIterable {
    case bamboo
    case character
    case dot
    
    var assetPrefix: String {
        switch self {
        case .bamboo: return "pict"
        case .character: return "picU"
        case .dot: return "picV"
        }
    }
    
    var label: String {
        switch self {
        case .bamboo: return "Bamboo"
        case .character: return "Character"
        case .dot: return "Dot"
        }
    }
}

// MARK: - Tile Definition
struct MosaicGlyphSpec: Hashable {
    let identifier: String
    let numericValue: Int
    let clan: MosaicGlyphFamily
    let depiction: UIImage
    
    init(value: Int, clan: MosaicGlyphFamily) {
        self.identifier = "\(clan.assetPrefix)_\(value)"
        self.numericValue = value
        self.clan = clan
        self.depiction = UIImage(named: "\(clan.assetPrefix) \(value)") ?? UIImage()
    }
}

// MARK: - Gameplay Modes
enum GameplayModeVariant: String, CaseIterable {
    case uniform = "Harmonic Loop"
    case diverse = "Prismatic Run"
}

// MARK: - Game Chronicle
struct VoyageRegister: Codable, Equatable {
    let token: String
    let imprintDate: Date
    let terminalScore: Int
    let elapsedSeconds: Int
    let schemeDescription: String
    
    init(score: Int, duration: Int, mode: String) {
        token = UUID().uuidString
        imprintDate = Date()
        terminalScore = score
        elapsedSeconds = duration
        schemeDescription = mode
    }
}

// MARK: - Ledger Source
final class HeptagramLedger {
    
    static let shared = HeptagramLedger()
    
    private lazy var bambooGlyphs: [MosaicGlyphSpec] = Self.compileSuite(for: .bamboo)
    private lazy var characterGlyphs: [MosaicGlyphSpec] = Self.compileSuite(for: .character)
    private lazy var dotGlyphs: [MosaicGlyphSpec] = Self.compileSuite(for: .dot)
    
    private static func compileSuite(for clan: MosaicGlyphFamily) -> [MosaicGlyphSpec] {
        return (1...9).map { MosaicGlyphSpec(value: $0, clan: clan) }
    }
    
    func suite(for clan: MosaicGlyphFamily) -> [MosaicGlyphSpec] {
        switch clan {
        case .bamboo: return bambooGlyphs
        case .character: return characterGlyphs
        case .dot: return dotGlyphs
        }
    }
    
    func mixedSuite(count: Int) -> [MosaicGlyphSpec] {
        let merged = bambooGlyphs + characterGlyphs + dotGlyphs
        return Array(merged.shuffled().prefix(count))
    }
    
    func randomClan() -> MosaicGlyphFamily {
        return MosaicGlyphFamily.allCases.randomElement() ?? .bamboo
    }
}


