import Foundation

class ScoreManager {

    private static let highScoreKey = "FlappyBirds_HighScore"
    private static let maximumMultiplier = 5

    private(set) var currentScore: Int = 0
    private(set) var starStreak: Int = 0

    var currentMultiplier: Int {
        max(1, starStreak)
    }

    var highScore: Int {
        get { UserDefaults.standard.integer(forKey: Self.highScoreKey) }
        set { UserDefaults.standard.set(newValue, forKey: Self.highScoreKey) }
    }

    func recordGate(starCollected: Bool) {
        starStreak = starCollected ? min(starStreak + 1, Self.maximumMultiplier) : 0
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
    }
}
