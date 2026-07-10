import XCTest
@testable import FlappyBirds

final class BirdNodeTests: XCTestCase {
    func testFlapSetsConfiguredUpwardVelocity() {
        let bird = BirdNode()

        bird.flap()

        XCTAssertEqual(bird.physicsBody?.velocity.dy, BirdNode.flapVelocity)
    }
}

final class ScoreManagerTests: XCTestCase {
    func testStarChainCapsAtFiveAndMissResetsIt() {
        let score = ScoreManager()

        score.recordGate(starCollected: true)
        XCTAssertEqual(score.currentScore, 1)
        XCTAssertEqual(score.currentMultiplier, 1)
        XCTAssertEqual(score.gatesPassed, 1)

        score.recordGate(starCollected: true)
        XCTAssertEqual(score.currentScore, 3)
        XCTAssertEqual(score.currentMultiplier, 2)

        for _ in 0..<5 {
            score.recordGate(starCollected: true)
        }
        XCTAssertEqual(score.currentMultiplier, 5)
        XCTAssertEqual(score.starStreak, 7)
        XCTAssertEqual(score.longestStarStreak, 7)

        let scoreBeforeMiss = score.currentScore
        score.recordGate(starCollected: false)
        XCTAssertEqual(score.currentScore, scoreBeforeMiss + 1)
        XCTAssertEqual(score.currentMultiplier, 1)
        XCTAssertEqual(score.starStreak, 0)
        XCTAssertEqual(score.longestStarStreak, 7)

        score.reset()
        XCTAssertEqual(score.currentScore, 0)
        XCTAssertEqual(score.starStreak, 0)
        XCTAssertEqual(score.gatesPassed, 0)
        XCTAssertEqual(score.longestStarStreak, 0)
    }

    func testHighScoreOnlyMovesUp() throws {
        let suiteName = "ScoreManagerTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let score = ScoreManager(defaults: defaults)

        score.recordGate(starCollected: true)
        score.recordGate(starCollected: true)
        score.saveHighScore()
        XCTAssertEqual(score.highScore, 3)

        score.reset()
        score.recordGate(starCollected: false)
        score.saveHighScore()
        XCTAssertEqual(score.highScore, 3)
    }
}

final class GameDifficultyTests: XCTestCase {
    func testDifficultyStepsAndCaps() {
        let initial = GameDifficulty.forGatesPassed(-1)
        XCTAssertEqual(initial.pipeSpeed, 200)
        XCTAssertEqual(initial.gapHeight, 180)
        XCTAssertEqual(initial.spawnInterval, 2.5)

        XCTAssertEqual(GameDifficulty.forGatesPassed(4), initial)

        let firstStep = GameDifficulty.forGatesPassed(5)
        XCTAssertEqual(firstStep.pipeSpeed, 220)
        XCTAssertEqual(firstStep.gapHeight, 172.5)
        XCTAssertEqual(firstStep.spawnInterval, 2.35, accuracy: 0.001)

        let cap = GameDifficulty.forGatesPassed(20)
        XCTAssertEqual(cap.pipeSpeed, 280)
        XCTAssertEqual(cap.gapHeight, 150)
        XCTAssertEqual(cap.spawnInterval, 1.9, accuracy: 0.001)
        XCTAssertEqual(GameDifficulty.forGatesPassed(100), cap)
    }
}
