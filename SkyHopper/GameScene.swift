import SpriteKit
import UIKit

struct GameDifficulty: Equatable {
    let pipeSpeed: CGFloat
    let gapHeight: CGFloat
    let spawnInterval: TimeInterval

    static func forGatesPassed(_ gatesPassed: Int) -> GameDifficulty {
        let level = min(max(gatesPassed, 0) / 5, 4)
        return GameDifficulty(
            pipeSpeed: 200 + CGFloat(level * 20),
            gapHeight: 180 - CGFloat(level) * 7.5,
            spawnInterval: 2.5 - Double(level) * 0.15
        )
    }
}

class GameScene: SKScene, SKPhysicsContactDelegate {

    // SpriteKit converts gravity units to screen points (about 150 pt per unit).
    static let gravityY: CGFloat = -4.2

    private enum ActionKey {
        static let birdRotation = "birdRotation"
    }

    private enum PreferenceKey {
        static let soundEnabled = "SkyHopper_SoundEnabled"
        static let hasSeenTutorial = "SkyHopper_HasSeenTutorial"
    }

    // MARK: - Properties
    private var bird: BirdNode!
    private var ground: GroundNode!
    private var scoreManager = ScoreManager()

    private var gameState: GameState = .ready

    // UI labels
    private var scoreLabel: SKLabelNode!
    private var comboLabel: SKLabelNode!
    private var highScoreLabel: SKLabelNode!
    private var titleLabel: SKLabelNode!
    private var tapToStartLabel: SKLabelNode!
    private var gameOverLabel: SKLabelNode!
    private var restartLabel: SKLabelNode!
    private var gameOverScoreLabel: SKLabelNode!
    private var privacyLabel: SKLabelNode!
    private var soundLabel: SKLabelNode!
    private var tutorialLabel: SKLabelNode!

    // Pipe spawning
    private var pipeTimer: Timer?
    private var pausedForInactivity = false

    private let flapFeedback = UIImpactFeedbackGenerator(style: .light)
    private let starFeedback = UISelectionFeedbackGenerator()
    private let collisionFeedback = UIImpactFeedbackGenerator(style: .heavy)

    private var isSoundEnabled: Bool {
        get { UserDefaults.standard.object(forKey: PreferenceKey.soundEnabled) as? Bool ?? true }
        set { UserDefaults.standard.set(newValue, forKey: PreferenceKey.soundEnabled) }
    }

    private var hasSeenTutorial: Bool {
        get { UserDefaults.standard.bool(forKey: PreferenceKey.hasSeenTutorial) }
        set { UserDefaults.standard.set(newValue, forKey: PreferenceKey.hasSeenTutorial) }
    }

    private var currentDifficulty: GameDifficulty {
        GameDifficulty.forGatesPassed(scoreManager.gatesPassed)
    }

    // MARK: - Scene Lifecycle

    override func didMove(to view: SKView) {
        isUserInteractionEnabled = true
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(pauseForInactivity),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(resumeAfterInactivity),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )

        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: Self.gravityY)

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
        bgTexture.filteringMode = .nearest
        let bgNode = SKSpriteNode(texture: bgTexture, size: size)
        bgNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        bgNode.zPosition = -10
        addChild(bgNode)
    }

    // MARK: - Ground

    private func setupGround() {
        ground = GroundNode(totalWidth: size.width)
        ground.name = "ground"
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

    private func localized(_ key: String) -> String {
        NSLocalizedString(key, comment: "")
    }

    private func localizedFormat(_ key: String, _ value: Int) -> String {
        String(format: localized(key), value)
    }

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

        comboLabel = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        comboLabel.fontSize = 18
        comboLabel.fontColor = UIColor(red: 1.0, green: 0.82, blue: 0.4, alpha: 1.0)
        comboLabel.position = CGPoint(x: size.width / 2, y: size.height - 120)
        comboLabel.zPosition = 20
        comboLabel.isHidden = true
        addChild(comboLabel)

        // High score label
        highScoreLabel = SKLabelNode(fontNamed: "HelveticaNeue")
        highScoreLabel.fontSize = 18
        highScoreLabel.fontColor = .white
        highScoreLabel.position = CGPoint(x: size.width / 2, y: size.height - 150)
        highScoreLabel.zPosition = 20
        highScoreLabel.text = localizedFormat("best_format", scoreManager.highScore)
        addChild(highScoreLabel)

        // Title label
        titleLabel = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        titleLabel.fontSize = 42
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.7)
        titleLabel.zPosition = 20
        titleLabel.text = localized("game_title")
        addChild(titleLabel)

        // Tap to start
        tapToStartLabel = SKLabelNode(fontNamed: "HelveticaNeue")
        tapToStartLabel.fontSize = 22
        tapToStartLabel.fontColor = .white
        tapToStartLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.55)
        tapToStartLabel.zPosition = 20
        tapToStartLabel.text = localized("tap_to_start")
        addChild(tapToStartLabel)

        tutorialLabel = SKLabelNode(fontNamed: "HelveticaNeue")
        tutorialLabel.fontSize = 15
        tutorialLabel.fontColor = UIColor.white.withAlphaComponent(0.9)
        tutorialLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.45)
        tutorialLabel.zPosition = 20
        tutorialLabel.text = localized("tutorial")
        addChild(tutorialLabel)

        // Game over
        gameOverLabel = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        gameOverLabel.fontSize = 48
        gameOverLabel.fontColor = UIColor(red: 0.9, green: 0.2, blue: 0.2, alpha: 1.0)
        gameOverLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.6)
        gameOverLabel.zPosition = 20
        gameOverLabel.text = localized("game_over")
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
        restartLabel.text = localized("tap_to_restart")
        restartLabel.isHidden = true
        addChild(restartLabel)

        privacyLabel = SKLabelNode(fontNamed: "HelveticaNeue")
        privacyLabel.fontSize = 14
        privacyLabel.fontColor = UIColor.white.withAlphaComponent(0.85)
        privacyLabel.position = CGPoint(x: size.width / 2, y: GroundNode.groundHeight + 24)
        privacyLabel.zPosition = 20
        privacyLabel.text = localized("privacy")
        privacyLabel.isAccessibilityElement = true
        privacyLabel.accessibilityLabel = localized("privacy")
        privacyLabel.accessibilityHint = localized("privacy_help")
        addChild(privacyLabel)

        soundLabel = SKLabelNode(fontNamed: "HelveticaNeue")
        soundLabel.fontSize = 14
        soundLabel.fontColor = UIColor.white.withAlphaComponent(0.85)
        soundLabel.position = CGPoint(x: size.width / 2, y: GroundNode.groundHeight + 48)
        soundLabel.zPosition = 20
        soundLabel.isAccessibilityElement = true
        soundLabel.accessibilityHint = localized("sound_help")
        updateSoundLabel()
        addChild(soundLabel)
    }

    // MARK: - States

    private func updateSoundLabel() {
        soundLabel.text = localized(isSoundEnabled ? "sound_on" : "sound_off")
        soundLabel.accessibilityLabel = soundLabel.text
    }

    private func playSound(_ name: String) {
        guard isSoundEnabled else { return }
        run(SKAction.playSoundFileNamed(name, waitForCompletion: false))
    }

    private func flapBird() {
        bird.flap()
        playSound("flap.wav")
        flapFeedback.impactOccurred()
    }

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
        tutorialLabel.isHidden = hasSeenTutorial
        scoreLabel.isHidden = true
        comboLabel.isHidden = true
        gameOverLabel.isHidden = true
        gameOverScoreLabel.isHidden = true
        restartLabel.isHidden = true
        privacyLabel.isHidden = false
        soundLabel.isHidden = false
        highScoreLabel.text = localizedFormat("best_format", scoreManager.highScore)
    }

    private func enterPlayingState() {
        gameState = .playing
        bird.removeAllActions()
        bird.physicsBody?.affectedByGravity = true
        flapBird()
        hasSeenTutorial = true

        scoreManager.reset()
        scoreLabel.text = "0"
        comboLabel.isHidden = true

        titleLabel.isHidden = true
        tapToStartLabel.isHidden = true
        tutorialLabel.isHidden = true
        scoreLabel.isHidden = false
        gameOverLabel.isHidden = true
        gameOverScoreLabel.isHidden = true
        restartLabel.isHidden = true
        privacyLabel.isHidden = true
        soundLabel.isHidden = true

        startSpawningPipes()
    }

    private func enterGameOverState() {
        gameState = .gameOver
        playSound("hit.wav")
        collisionFeedback.impactOccurred()
        comboLabel.isHidden = true
        privacyLabel.isHidden = true
        soundLabel.isHidden = true
        bird.disablePhysics()
        bird.removeAction(forKey: ActionKey.birdRotation)

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
            guard let self, self.gameState == .gameOver else { return }
            self.gameOverLabel.isHidden = false
            self.gameOverScoreLabel.text = self.localizedFormat("score_format", self.scoreManager.currentScore)
            self.gameOverScoreLabel.isHidden = false
            self.restartLabel.isHidden = false
            self.highScoreLabel.text = self.localizedFormat("best_format", self.scoreManager.highScore)
        }
    }

    // MARK: - Pipe Spawning

    private func startSpawningPipes() {
        stopSpawningPipes()
        spawnPipe()
        scheduleNextPipe()
    }

    private func scheduleNextPipe() {
        guard gameState == .playing, !pausedForInactivity else { return }
        pipeTimer = Timer.scheduledTimer(withTimeInterval: currentDifficulty.spawnInterval, repeats: false) { [weak self] _ in
            guard let self, self.gameState == .playing, !self.pausedForInactivity else { return }
            self.spawnPipe()
            self.scheduleNextPipe()
        }
    }

    private func stopSpawningPipes() {
        pipeTimer?.invalidate()
        pipeTimer = nil
    }

    private func spawnPipe() {
        guard gameState == .playing else { return }
        let difficulty = currentDifficulty

        // Random gap center Y
        let minY = GroundNode.groundHeight + 120
        let maxY = size.height - 120
        let gapCenterY = CGFloat.random(in: minY...maxY)

        let pipe = PipeNode(
            totalHeight: size.height,
            centerY: gapCenterY,
            gapHeight: difficulty.gapHeight,
            speed: difficulty.pipeSpeed
        )
        pipe.position = CGPoint(x: size.width + PipeNode.pipeWidth, y: 0)
        pipe.zPosition = 5
        addChild(pipe)
    }

    // MARK: - Touch Handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameState == .ready, let touch = touches.first {
            let touchedNodes = nodes(at: touch.location(in: self))

            if touchedNodes.contains(where: { $0 === soundLabel }) {
                isSoundEnabled.toggle()
                updateSoundLabel()
                return
            }

            if touchedNodes.contains(where: { $0 === privacyLabel }),
               let url = URL(string: "https://mustafarec.github.io/flappybirds/privacy/") {
                UIApplication.shared.open(url)
                return
            }
        }

        switch gameState {
        case .ready:
            enterPlayingState()
        case .playing:
            flapBird()
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

        enterReadyState()
    }

    // MARK: - Physics Contact Delegate

    func didBegin(_ contact: SKPhysicsContact) {
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB

        let catA = bodyA.categoryBitMask
        let catB = bodyB.categoryBitMask

        // Bird hit pipe
        if (catA == BirdNode.birdCategory && catB == BirdNode.pipeCategory) ||
           (catB == BirdNode.birdCategory && catA == BirdNode.pipeCategory) {
            if gameState == .playing {
                enterGameOverState()
            }
        }

        // Bird passed through score sensor
        if gameState == .playing,
           (catA == BirdNode.birdCategory && catB == BirdNode.scoreCategory) ||
           (catB == BirdNode.birdCategory && catA == BirdNode.scoreCategory) {
            let sensorBody: SKPhysicsBody = (catA == BirdNode.scoreCategory) ? bodyA : bodyB
            if let sensorNode = sensorBody.node,
               let pipeNode = sensorNode.parent as? PipeNode,
               !pipeNode.scored {
                pipeNode.scored = true
                scoreManager.recordGate(starCollected: pipeNode.starCollected)
                scoreLabel.text = "\(scoreManager.currentScore)"
                comboLabel.text = localizedFormat("combo_format", scoreManager.currentMultiplier)
                comboLabel.isHidden = scoreManager.currentMultiplier < 2
                playSound("score.wav")

                // Flash score label
                let scaleUp = SKAction.scale(to: 1.3, duration: 0.1)
                let scaleDown = SKAction.scale(to: 1.0, duration: 0.1)
                scoreLabel.run(SKAction.sequence([scaleUp, scaleDown]))
            }
        }

        // Bird collected the star before passing the gate
        if gameState == .playing,
           (catA == BirdNode.birdCategory && catB == BirdNode.starCategory) ||
           (catB == BirdNode.birdCategory && catA == BirdNode.starCategory) {
            let starBody: SKPhysicsBody = (catA == BirdNode.starCategory) ? bodyA : bodyB
            if let starNode = starBody.node,
               let pipeNode = starNode.parent as? PipeNode,
               !pipeNode.starCollected {
                pipeNode.starCollected = true
                starNode.removeFromParent()
                playSound("star.wav")
                starFeedback.selectionChanged()
            }
        }
    }

    // MARK: - Update Loop

    static func isOutOfBounds(_ centerY: CGFloat, sceneHeight: CGFloat) -> Bool {
        centerY <= GroundNode.groundHeight + BirdNode.birdSize.height / 2 ||
        centerY >= sceneHeight - BirdNode.birdSize.height / 2
    }

    override func update(_ currentTime: TimeInterval) {
        if gameState == .playing, Self.isOutOfBounds(bird.position.y, sceneHeight: size.height) {
            enterGameOverState()
            return
        }

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
            bird.run(rotate, withKey: ActionKey.birdRotation)
        }
    }

    override func willMove(from view: SKView) {
        stopSpawningPipes()
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func pauseForInactivity() {
        guard gameState == .playing, !pausedForInactivity else { return }
        pausedForInactivity = true
        stopSpawningPipes()
        isPaused = true
    }

    @objc private func resumeAfterInactivity() {
        guard pausedForInactivity else { return }
        pausedForInactivity = false
        isPaused = false
        if gameState == .playing {
            scheduleNextPipe()
        }
    }
}
