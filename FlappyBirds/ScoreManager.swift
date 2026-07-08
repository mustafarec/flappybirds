import Foundation

class ScoreManager {

    private static let highScoreKey = "FlappyBirds_HighScore"

    var currentScore: Int = 0

    var highScore: Int {
        get { UserDefaults.standard.integer(forKey: Self.highScoreKey) }
        set { UserDefaults.standard.set(newValue, forKey: Self.highScoreKey) }
    }

    func incrementScore() {
        currentScore += 1
    }

    func saveHighScore() {
        if currentScore > highScore {
            highScore = currentScore
        }
    }

    func reset() {
        currentScore = 0
    }
}
