import SpriteKit

class PipeNode: SKNode {

    // MARK: - Constants (pipe asset: 52x320)
    static let pipeWidth: CGFloat = 52
    private let gapHeight: CGFloat = 180      // vertical gap between top and bottom pipes
    private let pipeSpeed: CGFloat = -200     // pixels per second, moving left

    // MARK: - Track if score has been counted
    var scored: Bool = false

    // MARK: - Score sensor
    private var scoreSensor: SKSpriteNode!

    init(totalHeight: CGFloat, centerY: CGFloat) {
        super.init()
        setupPipes(totalHeight: totalHeight, centerY: centerY)
        setupScoreSensor(totalHeight: totalHeight, centerY: centerY)
        startMoving()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupPipes(totalHeight: CGFloat, centerY: CGFloat) {
        let halfGap = gapHeight / 2
        let topPipeHeight = totalHeight - (centerY + halfGap)
        let bottomPipeHeight = centerY - halfGap

        // Bottom pipe (normal orientation)
        let bottomPipe = SKSpriteNode(imageNamed: "pipe")
        bottomPipe.anchorPoint = CGPoint(x: 0.5, y: 0)
        bottomPipe.size = CGSize(width: Self.pipeWidth, height: bottomPipeHeight)
        bottomPipe.position = CGPoint(x: Self.pipeWidth / 2, y: 0)
        bottomPipe.centerRect = centerRectForPipe(textureHeight: bottomPipe.texture!.size().height)
        bottomPipe.physicsBody = createPipePhysics(size: bottomPipe.size, position: bottomPipe.position)
        addChild(bottomPipe)

        // Top pipe (flipped vertically)
        let topPipe = SKSpriteNode(imageNamed: "pipe")
        topPipe.anchorPoint = CGPoint(x: 0.5, y: 1)
        topPipe.yScale = -1
        topPipe.size = CGSize(width: Self.pipeWidth, height: topPipeHeight)
        topPipe.position = CGPoint(x: Self.pipeWidth / 2, y: totalHeight)
        topPipe.centerRect = centerRectForPipe(textureHeight: topPipe.texture!.size().height)
        topPipe.physicsBody = createPipePhysics(size: topPipe.size, position: topPipe.position)
        addChild(topPipe)
    }

    /// Creates a centerRect that keeps the pipe caps from stretching — only the middle body area stretches.
    private func centerRectForPipe(textureHeight: CGFloat) -> CGRect {
        let capHeight: CGFloat = 30 / textureHeight   // top/bottom cap in texture coords
        return CGRect(x: 0, y: capHeight, width: 1, height: 1 - 2 * capHeight)
    }

    private func setupScoreSensor(totalHeight: CGFloat, centerY: CGFloat) {
        let sensorHeight: CGFloat = gapHeight
        scoreSensor = SKSpriteNode(color: .clear, size: CGSize(width: 10, height: sensorHeight))
        scoreSensor.position = CGPoint(x: Self.pipeWidth / 2, y: centerY)
        scoreSensor.physicsBody = SKPhysicsBody(rectangleOf: scoreSensor.size)
        scoreSensor.physicsBody?.categoryBitMask = BirdNode.scoreCategory
        scoreSensor.physicsBody?.contactTestBitMask = BirdNode.birdCategory
        scoreSensor.physicsBody?.collisionBitMask = 0
        scoreSensor.physicsBody?.affectedByGravity = false
        scoreSensor.physicsBody?.isDynamic = false
        addChild(scoreSensor)
    }

    private func createPipePhysics(size: CGSize, position: CGPoint) -> SKPhysicsBody {
        let body = SKPhysicsBody(rectangleOf: size, center: position)
        body.categoryBitMask = BirdNode.pipeCategory
        body.collisionBitMask = BirdNode.birdCategory
        body.contactTestBitMask = BirdNode.birdCategory
        body.affectedByGravity = false
        body.isDynamic = false
        return body
    }

    private func startMoving() {
        let moveLeft = SKAction.moveBy(x: -2000, y: 0, duration: 2000 / abs(pipeSpeed))
        let remove = SKAction.removeFromParent()
        run(SKAction.sequence([moveLeft, remove]))
    }

    func stop() {
        removeAllActions()
    }
}
