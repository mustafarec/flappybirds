import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {

    // MARK: - Properties
    private var bird: BirdNode!
    private var ground: GroundNode!
    private var scoreManager = ScoreManager()

    private var gameState: GameState = .ready

    // UI labels
    private var scoreLabel: SKLabelNode!
    private var highScoreLabel: SKLabelNode!
    private var titleLabel: SKLabelNode!
    private var tapToStartLabel: SKLabelNode!
    private var gameOverLabel: SKLabelNode!
    private var restartLabel: SKLabelNode!
    private var gameOverScoreLabel: SKLabelNode!

    // Pipe spawning
    private var pipeTimer: Timer?
    private let pipeSpawnInterval: TimeInterval = 2.5

    // MARK: - Scene Lifecycle

    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)

        setupBackground()
        setupGround()
        setupBird()
        setupLabels()
        enterReadyState()
    }

    // MARK: - Background

    private func setupBackground() {
        // Use background image (288x512), scale to fill screen
        let bgTexture = SKTexture(imageNamed: "background")
        let bgNode = SKSpriteNode(texture: bgTexture, size: size)
        bgNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        bgNode.zPosition = -10
        addChild(bgNode)

        // Add a few semi-transparent moving clouds for depth
        for i in 0..<3 {
            let cloud = createCloud()
            cloud.position = CGPoint(
                x: CGFloat.random(in: 0...size.width),
                y: size.height * 0.72 + CGFloat.random(in: -30...30)
            )
            cloud.alpha = 0.4
            cloud.zPosition = -5
            addChild(cloud)

            let drift = SKAction.moveBy(x: -size.width - 120, y: 0, duration: 12 + Double.random(in: 0...6))
            let reset = SKAction.moveBy(x: size.width + 120, y: 0, duration: 0)
            cloud.run(SKAction.repeatForever(SKAction.sequence([drift, reset])))
        }
    }

    private func createCloud() -> SKSpriteNode {
        let cloudSize = CGSize(width: 80, height: 35)
        let renderer = UIGraphicsImageRenderer(size: cloudSize)
        let image = renderer.image { ctx in
            UIColor.white.withAlphaComponent(0.8).setFill()
            let path = UIBezierPath(roundedRect: CGRect(origin: .zero, size: cloudSize), cornerRadius: 17)
            path.fill()
        }
        return SKSpriteNode(texture: SKTexture(image: image))
    }

    // MARK: - Ground

    private func setupGround() {
        ground = GroundNode(totalWidth: size.width)
        ground.position = CGPoint(x: 0, y: 0)
        ground.zPosition = 5
        addChild(ground)
    }

    // MARK: - Bird

    private func setupBird() {
        bird = BirdNode()
        bird.position = CGPoint(x: size.width * 0.3, y: size.height * 0.5)
        bird.zPosition = 10
        addChild(bird)
    }

    // MARK: - Labels

    private func setupLabels() {
        // Score label - top center
        scoreLabel = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        scoreLabel.fontSize = 48
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: size.width / 2, y: size.height - 80)
        scoreLabel.zPosition = 20
        scoreLabel.text = "0"
        scoreLabel.isHidden = true
        addChild(scoreLabel)

        // High score label
        highScoreLabel = SKLabelNode(fontNamed: "HelveticaNeue")
        highScoreLabel.fontSize = 18
        highScoreLabel.fontColor = .white
        highScoreLabel.position = CGPoint(x: size.width / 2, y: size.height - 110)
        highScoreLabel.zPosition = 20
        highScoreLabel.text = "Best: \(scoreManager.highScore)"
        addChild(highScoreLabel)

        // Title label
        titleLabel = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        titleLabel.fontSize = 42
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.7)
        titleLabel.zPosition = 20
        titleLabel.text = "Flappy Birds"
        addChild(titleLabel)

        // Tap to start
        tapToStartLabel = SKLabelNode(fontNamed: "HelveticaNeue")
        tapToStartLabel.fontSize = 22
        tapToStartLabel.fontColor = .white
        tapToStartLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.55)
        tapToStartLabel.zPosition = 20
        tapToStartLabel.text = "Tap to Start"
        addChild(tapToStartLabel)

        // Game over
        gameOverLabel = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        gameOverLabel.fontSize = 48
        gameOverLabel.fontColor = UIColor(red: 0.9, green: 0.2, blue: 0.2, alpha: 1.0)
        gameOverLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.6)
        gameOverLabel.zPosition = 20
        gameOverLabel.text = "Game Over"
        gameOverLabel.isHidden = true
        addChild(gameOverLabel)

        // Game over score
        gameOverScoreLabel = SKLabelNode(fontNamed: "HelveticaNeue")
        gameOverScoreLabel.fontSize = 24
        gameOverScoreLabel.fontColor = .white
        gameOverScoreLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.52)
        gameOverScoreLabel.zPosition = 20
        gameOverScoreLabel.isHidden = true
        addChild(gameOverScoreLabel)

        // Restart
        restartLabel = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        restartLabel.fontSize = 24
        restartLabel.fontColor = .white
        restartLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.44)
        restartLabel.zPosition = 20
        restartLabel.text = "Tap to Restart"
        restartLabel.isHidden = true
        addChild(restartLabel)
    }

    // MARK: - States

    private func enterReadyState() {
        gameState = .ready
        bird.enablePhysics()
        bird.physicsBody?.affectedByGravity = false

        // Gentle bobbing animation
        let bobUp = SKAction.moveBy(x: 0, y: 8, duration: 0.6)
        let bobDown = SKAction.moveBy(x: 0, y: -8, duration: 0.6)
        bobUp.timingMode = .easeInEaseOut
        bobDown.timingMode = .easeInEaseOut
        bird.run(SKAction.repeatForever(SKAction.sequence([bobUp, bobDown])))

        titleLabel.isHidden = false
        tapToStartLabel.isHidden = false
        scoreLabel.isHidden = true
        gameOverLabel.isHidden = true
        gameOverScoreLabel.isHidden = true
        restartLabel.isHidden = true
        highScoreLabel.text = "Best: \(scoreManager.highScore)"
    }

    private func enterPlayingState() {
        gameState = .playing
        bird.removeAllActions()
        bird.physicsBody?.affectedByGravity = true
        bird.flap()

        scoreManager.reset()
        scoreLabel.text = "0"

        titleLabel.isHidden = true
        tapToStartLabel.isHidden = true
        scoreLabel.isHidden = false
        gameOverLabel.isHidden = true
        gameOverScoreLabel.isHidden = true
        restartLabel.isHidden = true

        startSpawningPipes()
    }

    private func enterGameOverState() {
        gameState = .gameOver
        bird.disablePhysics()

        // Let bird fall visually
        let fall = SKAction.moveBy(x: 0, y: -size.height * 0.3, duration: 0.3)
        let rotate = SKAction.rotate(toAngle: -.pi / 2, duration: 0.3)
        bird.run(SKAction.group([fall, rotate]))

        scoreManager.saveHighScore()
        stopSpawningPipes()
        ground.stop()

        // Stop all pipes
        enumerateChildNodes(withName: "//*") { node, _ in
            if let pipe = node as? PipeNode {
                pipe.stop()
            }
        }

        // Show game over UI with delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
            guard let self = self else { return }
            self.gameOverLabel.isHidden = false
            self.gameOverScoreLabel.text = "Score: \(self.scoreManager.currentScore)"
            self.gameOverScoreLabel.isHidden = false
            self.restartLabel.isHidden = false
            self.highScoreLabel.text = "Best: \(self.scoreManager.highScore)"
        }
    }

    // MARK: - Pipe Spawning

    private func startSpawningPipes() {
        spawnPipe()
        pipeTimer = Timer.scheduledTimer(withTimeInterval: pipeSpawnInterval, repeats: true) { [weak self] _ in
            self?.spawnPipe()
        }
    }

    private func stopSpawningPipes() {
        pipeTimer?.invalidate()
        pipeTimer = nil
    }

    private func spawnPipe() {
        guard gameState == .playing else { return }

        // Random gap center Y
        let minY = GroundNode.groundHeight + 120
        let maxY = size.height - 120
        let gapCenterY = CGFloat.random(in: minY...maxY)

        let pipe = PipeNode(totalHeight: size.height, centerY: gapCenterY)
        pipe.position = CGPoint(x: size.width + PipeNode.pipeWidth, y: 0)
        pipe.zPosition = 5
        addChild(pipe)
    }

    // MARK: - Touch Handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        switch gameState {
        case .ready:
            enterPlayingState()
        case .playing:
            bird.flap()
        case .gameOver:
            restartGame()
        }
    }

    // MARK: - Restart

    private func restartGame() {
        // Remove all pipes
        enumerateChildNodes(withName: "//*") { node, _ in
            if node is PipeNode {
                node.removeFromParent()
            }
        }

        // Reset bird
        bird.removeAllActions()
        bird.position = CGPoint(x: size.width * 0.3, y: size.height * 0.5)
        bird.zRotation = 0
        bird.physicsBody?.velocity = .zero

        // Reset ground
        ground.removeAllActions()
        ground.removeFromParent()
        setupGround()

        // Remove clouds and re-add
        enumerateChildNodes(withName: "//*") { node, _ in
            if node is SKSpriteNode && node.zPosition == -5 {
                node.removeFromParent()
            }
        }

        enterReadyState()
    }

    // MARK: - Physics Contact Delegate

    func didBegin(_ contact: SKPhysicsContact) {
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB

        let catA = bodyA.categoryBitMask
        let catB = bodyB.categoryBitMask

        // Bird hit pipe or ground
        if (catA == BirdNode.birdCategory && (catB == BirdNode.pipeCategory || catB == BirdNode.groundCategory)) ||
           (catB == BirdNode.birdCategory && (catA == BirdNode.pipeCategory || catA == BirdNode.groundCategory)) {
            if gameState == .playing {
                enterGameOverState()
            }
        }

        // Bird passed through score sensor
        if (catA == BirdNode.birdCategory && catB == BirdNode.scoreCategory) ||
           (catB == BirdNode.birdCategory && catA == BirdNode.scoreCategory) {
            let sensorBody: SKPhysicsBody = (catA == BirdNode.scoreCategory) ? bodyA : bodyB
            if let sensorNode = sensorBody.node,
               let pipeNode = sensorNode.parent as? PipeNode,
               !pipeNode.scored {
                pipeNode.scored = true
                scoreManager.incrementScore()
                scoreLabel.text = "\(scoreManager.currentScore)"

                // Flash score label
                let scaleUp = SKAction.scale(to: 1.3, duration: 0.1)
                let scaleDown = SKAction.scale(to: 1.0, duration: 0.1)
                scoreLabel.run(SKAction.sequence([scaleUp, scaleDown]))
            }
        }
    }

    // MARK: - Update Loop

    override func update(_ currentTime: TimeInterval) {
        // Remove pipes that are off-screen (far left)
        enumerateChildNodes(withName: "//*") { node, _ in
            if let pipe = node as? PipeNode {
                if pipe.position.x < -PipeNode.pipeWidth * 2 {
                    pipe.removeFromParent()
                }
            }
        }

        // Keep bird rotation tied to velocity
        if gameState == .playing, let velocity = bird.physicsBody?.velocity {
            let angle = min(max(velocity.dy / 400 * .pi / 3, -.pi / 3), .pi / 4)
            let rotate = SKAction.rotate(toAngle: angle, duration: 0.1, shortestUnitArc: true)
            bird.run(rotate)
        }
    }
}
