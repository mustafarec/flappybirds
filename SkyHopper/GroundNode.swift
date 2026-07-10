import SpriteKit

class GroundNode: SKNode {

    // MARK: - Constants (ground asset: 336x112)
    static let groundHeight: CGFloat = 80
    private let groundSpeed: CGFloat = -200

    private var ground1: SKSpriteNode!
    private var ground2: SKSpriteNode!

    init(totalWidth: CGFloat) {
        super.init()
        setupGround(totalWidth: totalWidth)
        startScrolling(totalWidth: totalWidth)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupGround(totalWidth: CGFloat) {
        let texture = SKTexture(imageNamed: "ground")
        texture.filteringMode = .nearest

        // Scale to fill width, keep aspect ratio for height
        let groundWidth = totalWidth + 100
        let actualHeight = Self.groundHeight

        ground1 = SKSpriteNode(texture: texture, size: CGSize(width: groundWidth, height: actualHeight))
        ground1.anchorPoint = CGPoint(x: 0, y: 0)
        ground1.position = CGPoint(x: 0, y: 0)
        addChild(ground1)

        ground2 = SKSpriteNode(texture: texture, size: CGSize(width: groundWidth, height: actualHeight))
        ground2.anchorPoint = CGPoint(x: 0, y: 0)
        ground2.position = CGPoint(x: groundWidth, y: 0)
        addChild(ground2)

    }

    private func startScrolling(totalWidth: CGFloat) {
        let groundWidth = totalWidth + 100
        let moveDistance = groundWidth * 2
        let duration = moveDistance / abs(groundSpeed)

        let moveLeft = SKAction.moveBy(x: -moveDistance, y: 0, duration: duration)
        let reset = SKAction.moveBy(x: moveDistance, y: 0, duration: 0)
        let scrollForever = SKAction.repeatForever(SKAction.sequence([moveLeft, reset]))
        let firstWrap = SKAction.sequence([
            SKAction.moveBy(x: -groundWidth, y: 0, duration: duration / 2),
            reset
        ])
        ground1.run(SKAction.sequence([firstWrap, scrollForever]))
        ground2.run(scrollForever)
    }

    func stop() {
        ground1.removeAllActions()
        ground2.removeAllActions()
    }
}
