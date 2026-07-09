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

        // Scale to fill width, keep aspect ratio for height
        let groundWidth = totalWidth + 100
        let actualHeight = Self.groundHeight

        ground1 = SKSpriteNode(texture: texture, size: CGSize(width: groundWidth, height: actualHeight))
        ground1.anchorPoint = CGPoint(x: 0, y: 0)
        ground1.position = CGPoint(x: 0, y: 0)
        ground1.physicsBody = createGroundPhysics(node: ground1)
        addChild(ground1)

        ground2 = SKSpriteNode(texture: texture, size: CGSize(width: groundWidth, height: actualHeight))
        ground2.anchorPoint = CGPoint(x: 0, y: 0)
        ground2.position = CGPoint(x: groundWidth, y: 0)
        ground2.physicsBody = createGroundPhysics(node: ground2)
        addChild(ground2)
    }

    private func createGroundPhysics(node: SKSpriteNode) -> SKPhysicsBody {
        // Create a thinner physics body so the ground collision is at the top
        let body = SKPhysicsBody(rectangleOf: CGSize(width: node.size.width, height: 20),
                                  center: CGPoint(x: node.size.width / 2, y: node.size.height - 10))
        body.categoryBitMask = BirdNode.groundCategory
        body.collisionBitMask = BirdNode.birdCategory
        body.contactTestBitMask = BirdNode.birdCategory
        body.affectedByGravity = false
        body.isDynamic = false
        return body
    }

    private func startScrolling(totalWidth: CGFloat) {
        let groundWidth = totalWidth + 100
        let moveDistance = groundWidth
        let duration = moveDistance / abs(groundSpeed)

        let moveLeft = SKAction.moveBy(x: -moveDistance, y: 0, duration: duration)
        let reset = SKAction.moveBy(x: moveDistance * 2, y: 0, duration: 0)
        let scrollForever = SKAction.repeatForever(SKAction.sequence([moveLeft, reset]))
        ground1.run(scrollForever)

        let moveLeft2 = SKAction.moveBy(x: -moveDistance, y: 0, duration: duration)
        let reset2 = SKAction.moveBy(x: moveDistance * 2, y: 0, duration: 0)
        let scrollForever2 = SKAction.repeatForever(SKAction.sequence([moveLeft2, reset2]))
        ground2.run(scrollForever2)
    }

    func stop() {
        ground1.removeAllActions()
        ground2.removeAllActions()
    }
}
