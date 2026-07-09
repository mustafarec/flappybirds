import XCTest
@testable import FlappyBirds

final class BirdNodeTests: XCTestCase {
    func testFlapSetsConfiguredUpwardVelocity() {
        let bird = BirdNode()

        bird.flap()

        XCTAssertEqual(bird.physicsBody?.velocity.dy, BirdNode.flapVelocity)
    }
}
