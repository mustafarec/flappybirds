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

        score.recordGate(starCollected: true)
        XCTAssertEqual(score.currentScore, 3)
        XCTAssertEqual(score.currentMultiplier, 2)

        for _ in 0..<5 {
            score.recordGate(starCollected: true)
        }
        XCTAssertEqual(score.currentMultiplier, 5)

        let scoreBeforeMiss = score.currentScore
        score.recordGate(starCollected: false)
        XCTAssertEqual(score.currentScore, scoreBeforeMiss + 1)
        XCTAssertEqual(score.currentMultiplier, 1)

        score.reset()
        XCTAssertEqual(score.currentScore, 0)
        XCTAssertEqual(score.starStreak, 0)
    }
}
