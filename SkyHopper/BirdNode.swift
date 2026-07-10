import SpriteKit

class BirdNode: SKSpriteNode {

    // MARK: - Physics Categories
    static let birdCategory: UInt32 = 0x1 << 0
    static let pipeCategory: UInt32 = 0x1 << 1
    static let scoreCategory: UInt32 = 0x1 << 3   // invisible sensor for scoring
    static let starCategory: UInt32 = 0x1 << 4

    // MARK: - Bird size (asset: 68x48)
    static let birdSize: CGSize = CGSize(width: 68, height: 48)

    // MARK: - Flap
    static let flapVelocity: CGFloat = 300

    init() {
        let texture = SKTexture(imageNamed: "bird")
        texture.filteringMode = .nearest
        super.init(texture: texture, color: .clear, size: Self.birdSize)
        setupPhysics()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupPhysics() {
        // Use slightly smaller physics body for forgiving collisions
        physicsBody = SKPhysicsBody(circleOfRadius: Self.birdSize.width * 0.35)
        physicsBody?.categoryBitMask = Self.birdCategory
        physicsBody?.collisionBitMask = Self.pipeCategory
        physicsBody?.contactTestBitMask = Self.pipeCategory | Self.scoreCategory | Self.starCategory
        physicsBody?.affectedByGravity = true
        physicsBody?.allowsRotation = false
        physicsBody?.restitution = 0
        physicsBody?.mass = 1.0
    }

    func flap() {
        physicsBody?.velocity = CGVector(dx: 0, dy: Self.flapVelocity)
    }

    func disablePhysics() {
        physicsBody?.affectedByGravity = false
        physicsBody?.velocity = .zero
        physicsBody?.categoryBitMask = 0
    }

    func enablePhysics() {
        physicsBody?.affectedByGravity = true
        physicsBody?.categoryBitMask = Self.birdCategory
    }
}
