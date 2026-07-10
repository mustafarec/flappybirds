import Foundation

class ScoreManager {

    private static let highScoreKey = "FlappyBirds_HighScore"
    private static let maximumMultiplier = 5
    private let defaults: UserDefaults

    private(set) var currentScore: Int = 0
    private(set) var starStreak: Int = 0
    private(set) var gatesPassed: Int = 0
    private(set) var longestStarStreak: Int = 0

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var currentMultiplier: Int {
        min(max(1, starStreak), Self.maximumMultiplier)
    }

    var highScore: Int {
        get { defaults.integer(forKey: Self.highScoreKey) }
        set { defaults.set(newValue, forKey: Self.highScoreKey) }
    }

    func recordGate(starCollected: Bool) {
        gatesPassed += 1
        starStreak = starCollected ? starStreak + 1 : 0
        longestStarStreak = max(longestStarStreak, starStreak)
        currentScore += currentMultiplier
    }

    func saveHighScore() {
        if currentScore > highScore {
            highScore = currentScore
        }
    }

    func reset() {
        currentScore = 0
        starStreak = 0
        gatesPassed = 0
        longestStarStreak = 0
    }
}
