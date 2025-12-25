//
//  CollectionManager.swift
//  Shivering Ghosts
//
//  Created by cemal hekimoglu on 23.12.2025.
//
//  Outfit collection and saving system

import Foundation

// MARK: - Outfit Types
enum OutfitType: String, CaseIterable, Codable {
    case strawberrySweater = "strawberry_sweater"
    case watermelonHoodie = "watermelon_hoodie"
    case astronautSuit = "astronaut_suit"
    case grandpaVest = "grandpa_vest"
    case djHoodie = "dj_hoodie"
    case rainbowScarf = "rainbow_scarf"
    case christmasSweater = "christmas_sweater"
    case halloweenCape = "halloween_cape"
    
    var displayName: String {
        switch self {
        case .strawberrySweater: return "Strawberry Sweater"
        case .watermelonHoodie: return "Watermelon Hoodie"
        case .astronautSuit: return "Astronaut Suit"
        case .grandpaVest: return "Grandpa Vest"
        case .djHoodie: return "DJ Hoodie"
        case .rainbowScarf: return "Rainbow Scarf"
        case .christmasSweater: return "Christmas Sweater"
        case .halloweenCape: return "Halloween Cape"
        }
    }
    
    var emoji: String {
        switch self {
        case .strawberrySweater: return "🍓"
        case .watermelonHoodie: return "🍉"
        case .astronautSuit: return "👨‍🚀"
        case .grandpaVest: return "🧥"
        case .djHoodie: return "🎧"
        case .rainbowScarf: return "🌈"
        case .christmasSweater: return "🎄"
        case .halloweenCape: return "🎃"
        }
    }
    
    var unlockRequirement: String {
        switch self {
        case .strawberrySweater: return "Warm 10 ghosts"
        case .watermelonHoodie: return "Warm 25 ghosts"
        case .astronautSuit: return "Warm 1 Rare Ghost"
        case .grandpaVest: return "Warm 30 ghosts"
        case .djHoodie: return "Reach 50 combo"
        case .rainbowScarf: return "Use all colors in one round"
        case .christmasSweater: return "Play in December"
        case .halloweenCape: return "Play in October"
        }
    }
    
    var requiredScore: Int {
        switch self {
        case .strawberrySweater: return 100
        case .watermelonHoodie: return 250
        case .astronautSuit: return 500
        case .grandpaVest: return 300
        case .djHoodie: return 400
        case .rainbowScarf: return 350
        case .christmasSweater: return 200
        case .halloweenCape: return 200
        }
    }
}

// MARK: - Game Stats
struct GameStats: Codable {
    var totalGhostsWarmed: Int = 0
    var totalScore: Int = 0
    var highScore: Int = 0
    var maxCombo: Int = 0
    var rareGhostsWarmed: Int = 0
    var babyGhostsWarmed: Int = 0
    var pickyGhostsWarmed: Int = 0
    var totalGamesPlayed: Int = 0
    var maxLevel: Int = 1
    var allColorsUsedInOneRound: Bool = false
}

// MARK: - Settings
struct GameSettings: Codable {
    var musicEnabled: Bool = true
    var soundEffectsEnabled: Bool = true
    var hapticEnabled: Bool = true
    var musicVolume: Float = 0.5
    var sfxVolume: Float = 0.8
}

// MARK: - Collection Manager
class CollectionManager {
    static let shared = CollectionManager()
    
    private let unlockedOutfitsKey = "unlockedOutfits"
    private let gameStatsKey = "gameStats"
    private let settingsKey = "gameSettings"
    
    private(set) var unlockedOutfits: Set<OutfitType> = []
    private(set) var stats: GameStats = GameStats()
    private(set) var settings: GameSettings = GameSettings()
    
    private init() {
        loadData()
    }
    
    // MARK: - Save/Load
    func loadData() {
        let defaults = UserDefaults.standard
        
        // Load unlocked outfits
        if let data = defaults.data(forKey: unlockedOutfitsKey),
           let outfits = try? JSONDecoder().decode([OutfitType].self, from: data) {
            unlockedOutfits = Set(outfits)
        }
        
        // Load stats
        if let data = defaults.data(forKey: gameStatsKey),
           let loadedStats = try? JSONDecoder().decode(GameStats.self, from: data) {
            stats = loadedStats
        }
        
        // Load settings
        if let data = defaults.data(forKey: settingsKey),
           let loadedSettings = try? JSONDecoder().decode(GameSettings.self, from: data) {
            settings = loadedSettings
        }
    }
    
    func saveData() {
        let defaults = UserDefaults.standard
        
        // Save unlocked outfits
        if let data = try? JSONEncoder().encode(Array(unlockedOutfits)) {
            defaults.set(data, forKey: unlockedOutfitsKey)
        }
        
        // Save stats
        if let data = try? JSONEncoder().encode(stats) {
            defaults.set(data, forKey: gameStatsKey)
        }
        
        // Save settings
        if let data = try? JSONEncoder().encode(settings) {
            defaults.set(data, forKey: settingsKey)
        }
        
        defaults.synchronize()
    }
    
    // MARK: - Outfit Management
    func unlockOutfit(_ outfit: OutfitType) {
        unlockedOutfits.insert(outfit)
        saveData()
    }
    
    func isOutfitUnlocked(_ outfit: OutfitType) -> Bool {
        return unlockedOutfits.contains(outfit)
    }
    
    func checkUnlocks() -> [OutfitType] {
        var newUnlocks: [OutfitType] = []
        
        // Strawberry Sweater - 10 ghosts
        if stats.totalGhostsWarmed >= 10 && !isOutfitUnlocked(.strawberrySweater) {
            unlockOutfit(.strawberrySweater)
            newUnlocks.append(.strawberrySweater)
        }
        
        // Watermelon Hoodie - 25 ghosts
        if stats.totalGhostsWarmed >= 25 && !isOutfitUnlocked(.watermelonHoodie) {
            unlockOutfit(.watermelonHoodie)
            newUnlocks.append(.watermelonHoodie)
        }
        
        // Astronaut Suit - 1 rare ghost
        if stats.rareGhostsWarmed >= 1 && !isOutfitUnlocked(.astronautSuit) {
            unlockOutfit(.astronautSuit)
            newUnlocks.append(.astronautSuit)
        }
        
        // Grandpa Vest - warm 30 total ghosts
        if stats.totalGhostsWarmed >= 30 && !isOutfitUnlocked(.grandpaVest) {
            unlockOutfit(.grandpaVest)
            newUnlocks.append(.grandpaVest)
        }
        
        // DJ Hoodie - 50 max combo
        if stats.maxCombo >= 50 && !isOutfitUnlocked(.djHoodie) {
            unlockOutfit(.djHoodie)
            newUnlocks.append(.djHoodie)
        }
        
        // Rainbow Scarf - all colors in one round
        if stats.allColorsUsedInOneRound && !isOutfitUnlocked(.rainbowScarf) {
            unlockOutfit(.rainbowScarf)
            newUnlocks.append(.rainbowScarf)
        }
        
        // Seasonal outfits
        let month = Calendar.current.component(.month, from: Date())
        
        // Christmas Sweater - December
        if month == 12 && !isOutfitUnlocked(.christmasSweater) {
            unlockOutfit(.christmasSweater)
            newUnlocks.append(.christmasSweater)
        }
        
        // Halloween Cape - October
        if month == 10 && !isOutfitUnlocked(.halloweenCape) {
            unlockOutfit(.halloweenCape)
            newUnlocks.append(.halloweenCape)
        }
        
        return newUnlocks
    }
    
    // MARK: - Stats Management
    func updateStats(score: Int, ghostsWarmed: Int, maxCombo: Int, level: Int, 
                     ghostType: String, usedColors: Set<String>) {
        stats.totalScore += score
        stats.totalGhostsWarmed += ghostsWarmed
        stats.totalGamesPlayed += 1
        
        if score > stats.highScore {
            stats.highScore = score
        }
        
        if maxCombo > stats.maxCombo {
            stats.maxCombo = maxCombo
        }
        
        if level > stats.maxLevel {
            stats.maxLevel = level
        }
        
        // Track ghost types
        switch ghostType {
        case "rare": stats.rareGhostsWarmed += 1
        case "baby": stats.babyGhostsWarmed += 1
        case "picky": stats.pickyGhostsWarmed += 1
        default: break
        }
        
        // Check if all colors used
        if usedColors.count >= 7 {
            stats.allColorsUsedInOneRound = true
        }
        
        saveData()
    }
    
    // MARK: - Settings Management
    func updateSettings(_ newSettings: GameSettings) {
        settings = newSettings
        saveData()
    }
    
    func toggleMusic() {
        settings.musicEnabled.toggle()
        saveData()
    }
    
    func toggleSoundEffects() {
        settings.soundEffectsEnabled.toggle()
        saveData()
    }
    
    func toggleHaptic() {
        settings.hapticEnabled.toggle()
        saveData()
    }
    
    // MARK: - Collection Progress
    var collectionProgress: (unlocked: Int, total: Int) {
        return (unlockedOutfits.count, OutfitType.allCases.count)
    }
    
    var collectionProgressPercentage: Int {
        let total = OutfitType.allCases.count
        guard total > 0 else { return 0 }
        return Int((Double(unlockedOutfits.count) / Double(total)) * 100)
    }
}
