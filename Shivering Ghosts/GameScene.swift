//
//  GameScene.swift
//  Shivering Ghosts
//
//  Created by cemal hekimoglu on 23.12.2025.
//
//  "Not scary. Just a little cold." 👻❄️
//

import SpriteKit
import GameplayKit
import AVFoundation

// MARK: - Color Types
enum ClothingColor: String, CaseIterable {
    case red = "red"
    case yellow = "yellow"
    case green = "green"
    case blue = "blue"
    case purple = "purple"
    case orange = "orange"
    case pink = "pink"
    
    var color: UIColor {
        switch self {
        case .red: return UIColor(red: 1.0, green: 0.42, blue: 0.42, alpha: 1.0)      // #FF6B6B
        case .yellow: return UIColor(red: 1.0, green: 0.9, blue: 0.43, alpha: 1.0)    // #FFE66D
        case .green: return UIColor(red: 0.31, green: 0.8, blue: 0.77, alpha: 1.0)    // #4ECDC4
        case .blue: return UIColor(red: 0.27, green: 0.72, blue: 0.82, alpha: 1.0)    // #45B7D1
        case .purple: return UIColor(red: 0.63, green: 0.42, blue: 0.84, alpha: 1.0)  // #A06CD5
        case .orange: return UIColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 1.0)     // #FF9933
        case .pink: return UIColor(red: 1.0, green: 0.71, blue: 0.76, alpha: 1.0)     // #FFB5C2
        }
    }
    
    var emoji: String {
        switch self {
        case .red: return "🔴"
        case .yellow: return "🟡"
        case .green: return "🟢"
        case .blue: return "🔵"
        case .purple: return "🟣"
        case .orange: return "🟠"
        case .pink: return "🩷"
        }
    }
}

// MARK: - Clothing Item Types
enum ClothingType: String, CaseIterable {
    case hat = "hat"
    case scarf = "scarf"
    case sweater = "sweater"
    
    var emoji: String {
        switch self {
        case .hat: return "🎩"
        case .scarf: return "🧣"
        case .sweater: return "👔"
        }
    }
    
    var displayName: String {
        switch self {
        case .hat: return "Şapka"
        case .scarf: return "Atkı"
        case .sweater: return "Kazak"
        }
    }
}

// MARK: - Clothing Item
struct ClothingItem: Equatable {
    let type: ClothingType
    let color: ClothingColor
    
    var displayText: String {
        return "\(type.emoji) \(color.emoji)"
    }
    
    var imageName: String? {
        switch type {
        case .hat:
            switch color {
            case .red: return "kirmizi_sapka"
            case .blue: return "mavi_sapka"
            case .purple: return "cadi_sapkasi"
            default: return "kirmizi_sapka"
            }
        case .scarf:
            switch color {
            case .red: return "kirmizi_atki"
            case .blue: return "mavi_atki"
            case .green: return "yesil_atki"
            default: return "kirmizi_atki"
            }
        case .sweater:
            switch color {
            case .purple: return "mor_kazak"
            case .orange: return "turuncu_kazak"
            case .green: return "yesil_kazak"
            default: return "yesil_kazak"
            }
        }
    }
}

// MARK: - Ghost Type
enum GhostType: CaseIterable {
    case standard
    case baby
    case picky
    case rare
    
    var patternLength: Int {
        switch self {
        case .standard: return 3
        case .baby: return 2
        case .picky: return 3
        case .rare: return 5
        }
    }
    
    var allowsMistakes: Bool {
        return self != .picky
    }
    
    var name: String {
        switch self {
        case .standard: return "Shivering Ghost"
        case .baby: return "Baby Ghost"
        case .picky: return "Picky Ghost"
        case .rare: return "Rare Ghost"
        }
    }
    
    var scoreMultiplier: Double {
        switch self {
        case .standard: return 1.0
        case .baby: return 0.8  // Easier, less points
        case .picky: return 2.0  // Risky, more points
        case .rare: return 3.0   // Very hard, most points
        }
    }
    
    var sizeScale: CGFloat {
        switch self {
        case .standard: return 1.0
        case .baby: return 0.7
        case .picky: return 1.0
        case .rare: return 1.1
        }
    }
}

// MARK: - Game State
enum GameState {
    case menu
    case playing
    case success
    case failure
    case gameOver
}

// MARK: - Clothing Item Node
class ClothingItemNode: SKNode {
    let clothing: ClothingItem
    var originalPosition: CGPoint = .zero
    var isDragging = false
    
    private var backgroundShape: SKShapeNode!
    private var iconLabel: SKLabelNode!
    private var colorIndicator: SKShapeNode!
    
    init(clothing: ClothingItem, size: CGFloat = 60) {
        self.clothing = clothing
        super.init()
        
        self.name = "clothing_\(clothing.type.rawValue)_\(clothing.color.rawValue)"
        
        // Clothing type icon
        if let imgName = clothing.imageName {
            let texture = SKTexture(imageNamed: imgName)
            let sprite = SKSpriteNode(texture: texture)
            // Maintain aspect ratio
            let aspectRatio = texture.size().width / texture.size().height
            sprite.size = CGSize(width: size * aspectRatio, height: size)
            sprite.position = .zero
            addChild(sprite)
        } else {
            // Fallback to emoji
            iconLabel = SKLabelNode(text: clothing.type.emoji)
            iconLabel.fontSize = size * 0.5
            iconLabel.verticalAlignmentMode = .center
            iconLabel.position = CGPoint(x: 0, y: 0)
            addChild(iconLabel)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startDragging() {
        isDragging = true
        run(SKAction.scale(to: 1.2, duration: 0.1))
        zPosition = 100
        
        // Play drag sound if available
        playSFX("yarn_drag.mp3")
    }
    
    func stopDragging() {
        isDragging = false
        run(SKAction.scale(to: 1.0, duration: 0.1))
        zPosition = 10
    }
    
    func returnToOriginal() {
        run(SKAction.move(to: originalPosition, duration: 0.3))
    }
}

// MARK: - Ghost Node
class GhostNode: SKNode {
    let ghostType: GhostType
    var isShivering = true
    var appliedClothing: [ClothingItem] = []  // Changed from sweaterColors
    
    private var bodyNode: SKShapeNode!
    private var leftEye: SKShapeNode!
    private var rightEye: SKShapeNode!
    private var mouth: SKShapeNode!
    private var sweaterNode: SKNode?
    
    init(type: GhostType, size: CGSize) {
        self.ghostType = type
        super.init()
        
        setupBody(size: size)
        setupFace(size: size)
        startShivering()
        
        name = "ghost"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupBody(size: CGSize) {
        // Use PNG sprite based on ghost type
        let imageName: String
        switch ghostType {
        case .standard:
            imageName = "ghost_standard"
        case .baby:
            imageName = "ghost_baby"
        case .picky:
            imageName = "ghost_standard"  // Uses same as standard for now
        case .rare:
            imageName = "ghost_rare"
        }
        
        let texture = SKTexture(imageNamed: imageName)
        texture.filteringMode = .linear // Ensure smooth edges
        let sprite = SKSpriteNode(texture: texture, size: size)
        sprite.name = "ghostSprite"
        sprite.zPosition = -1
        
        // Alpha Threshold Shader to remove dirty borders
        let shader = SKShader(source: """
        void main() {
            vec4 color = texture2D(u_texture, v_tex_coord);
            if (color.a < 0.1) {
                discard;
            }
            gl_FragColor = color * v_color_mix.a;
        }
        """)
        sprite.shader = shader
        
        addChild(sprite)
        
        // Add type-specific animations
        addGhostAnimations(to: sprite)
        
        // Removed unused bodyNode to prevent issues
        // bodyNode = SKShapeNode()
        // bodyNode.isHidden = true
        // addChild(bodyNode)
    }
    
    private func addGhostAnimations(to sprite: SKSpriteNode) {
        // 1. Smooth Floating (Sine wave like)
        let floatUp = SKAction.moveBy(x: 0, y: 15, duration: 1.2)
        floatUp.timingMode = .easeInEaseOut
        let floatDown = SKAction.moveBy(x: 0, y: -15, duration: 1.2)
        floatDown.timingMode = .easeInEaseOut
        let floatSequence = SKAction.sequence([floatUp, floatDown])
        sprite.run(SKAction.repeatForever(floatSequence), withKey: "floating")
        
        // 2. Breathing (Subtle scale change)
        let breatheIn = SKAction.scale(to: 1.05, duration: 1.5)
        breatheIn.timingMode = .easeInEaseOut
        let breatheOut = SKAction.scale(to: 0.95, duration: 1.5)
        breatheOut.timingMode = .easeInEaseOut
        let breatheSequence = SKAction.sequence([breatheIn, breatheOut])
        sprite.run(SKAction.repeatForever(breatheSequence), withKey: "breathing")
        
        // 3. Subtle Swaying (Rotation)
        let swayLeft = SKAction.rotate(toAngle: 0.05, duration: 2.0)
        swayLeft.timingMode = .easeInEaseOut
        let swayRight = SKAction.rotate(toAngle: -0.05, duration: 2.0)
        swayRight.timingMode = .easeInEaseOut
        let swaySequence = SKAction.sequence([swayLeft, swayRight])
        sprite.run(SKAction.repeatForever(swaySequence), withKey: "swaying")
        
        // 4. Type-specific extra animations
        switch ghostType {
        case .baby:
            // Faster, more energetic movement
            let bounce = SKAction.sequence([
                SKAction.moveBy(x: 0, y: 10, duration: 0.4),
                SKAction.moveBy(x: 0, y: -10, duration: 0.4)
            ])
            bounce.timingMode = .easeInEaseOut
            sprite.run(SKAction.repeatForever(bounce))
            
        case .rare:
            // Glowing effect
            let glowOut = SKAction.fadeAlpha(to: 0.7, duration: 1.0)
            let glowIn = SKAction.fadeAlpha(to: 1.0, duration: 1.0)
            let glowSequence = SKAction.sequence([glowOut, glowIn])
            sprite.run(SKAction.repeatForever(glowSequence))
            
        default:
            break
        }
    }
    
    private func setupFace(size: CGSize) {
        // If a PNG sprite is present, use its embedded face; don't add vector eyes here.
        if childNode(withName: "ghostSprite") != nil { return }
        
        // Eyes
        let eyeRadius: CGFloat = size.width * 0.08
        let eyeY: CGFloat = size.height * 0.15
        let eyeSpacing: CGFloat = size.width * 0.15
        
        leftEye = SKShapeNode(circleOfRadius: eyeRadius)
        leftEye.fillColor = .black
        leftEye.position = CGPoint(x: -eyeSpacing, y: eyeY)
        addChild(leftEye)
        
        rightEye = SKShapeNode(circleOfRadius: eyeRadius)
        rightEye.fillColor = .black
        rightEye.position = CGPoint(x: eyeSpacing, y: eyeY)
        addChild(rightEye)
        
        // Mouth - initially sad/shivering
        updateMouth(happy: false)
    }
    
    private func updateMouth(happy: Bool) {
        // If we are using a PNG sprite, we don't need to update the vector mouth
        if childNode(withName: "ghostSprite") != nil {
            return
        }
        
        mouth?.removeFromParent()
        
        // Calculate dynamic dimensions based on sprite size if available
        var width: CGFloat = 40
        var height: CGFloat = 20
        var yOffset: CGFloat = -10
        
        if let sprite = childNode(withName: "ghostSprite") as? SKSpriteNode {
            width = sprite.size.width * 0.3
            height = sprite.size.height * 0.08
            yOffset = -sprite.size.height * 0.05 // Below center
        }
        
        let mouthPath = UIBezierPath()
        if happy {
            // Happy smile (Big and curvy)
            mouthPath.move(to: CGPoint(x: -width/2, y: yOffset))
            mouthPath.addQuadCurve(to: CGPoint(x: width/2, y: yOffset),
                                   controlPoint: CGPoint(x: 0, y: yOffset - height * 2)) // Deeper smile
        } else {
            // Shivering wavy mouth
            mouthPath.move(to: CGPoint(x: -width/3, y: yOffset))
            mouthPath.addCurve(to: CGPoint(x: width/3, y: yOffset),
                              controlPoint1: CGPoint(x: -width/6, y: yOffset - height),
                              controlPoint2: CGPoint(x: width/6, y: yOffset + height))
        }
        
        mouth = SKShapeNode(path: mouthPath.cgPath)
        mouth.strokeColor = .black
        mouth.lineWidth = 4 // Thicker lines for visibility
        mouth.lineCap = .round
        mouth.zPosition = 20 // Ensure it's above the sprite (and maybe sweater)
        
        // If we have a sprite, add mouth to it so it moves with it
        if let sprite = childNode(withName: "ghostSprite") as? SKSpriteNode {
             sprite.addChild(mouth)
        } else {
             addChild(mouth)
        }
    }

    
    func startShivering() {
        isShivering = true
        guard let sprite = childNode(withName: "ghostSprite") as? SKSpriteNode else { return }
        
        // Organic, random shivering
        let randomShiver = SKAction.customAction(withDuration: 0.1) { node, elapsedTime in
            let dx = CGFloat.random(in: -2...2)
            let dy = CGFloat.random(in: -2...2)
            let dr = CGFloat.random(in: -0.05...0.05)
            node.position = CGPoint(x: dx, y: dy)
            node.zRotation = dr
        }
        sprite.run(SKAction.repeatForever(randomShiver), withKey: "shiver")
        
        // Visual feedback for "cold" - slight blue tint
        // DISABLED to fix border artifacts (transparent pixels being tinted)
        // sprite.color = .cyan
        // sprite.colorBlendFactor = 0.3
        
        // Add cold particles
        addColdParticles()
        
        // Play shivering sound if available - Low Volume
        if CollectionManager.shared.settings.soundEffectsEnabled, let url = Bundle.main.url(forResource: "shiver", withExtension: "mp3") {
            let shiverNode = SKAudioNode(url: url)
            shiverNode.autoplayLooped = false
            shiverNode.name = "audio_shiver"
            
            // Set volume low (0.3)
            shiverNode.run(SKAction.changeVolume(to: 0.3, duration: 0))
            addChild(shiverNode)
            
            let playWait = SKAction.sequence([
                SKAction.play(),
                SKAction.wait(forDuration: 2.5)
            ])
            shiverNode.run(SKAction.repeatForever(playWait))
        }
    }
    
    func stopShivering() {
        isShivering = false
        removeAction(forKey: "shiverSound") // Old key cleanup
        childNode(withName: "audio_shiver")?.removeFromParent() // Remove audio node
        
        guard let sprite = childNode(withName: "ghostSprite") as? SKSpriteNode else { return }
        sprite.removeAction(forKey: "shiver")
        sprite.run(SKAction.rotate(toAngle: 0, duration: 0.2))
        sprite.run(SKAction.move(to: CGPoint.zero, duration: 0.2))
        sprite.run(SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.3)) // Remove blue tint
        
        childNode(withName: "coldParticles")?.removeFromParent()
        childNode(withName: "leafParticles")?.removeFromParent()
        childNode(withName: "rainParticles")?.removeFromParent()
    }
    
    private func addColdParticles() {
        // Clear old particles
        childNode(withName: "coldParticles")?.removeFromParent()
        childNode(withName: "leafParticles")?.removeFromParent()
        childNode(withName: "rainParticles")?.removeFromParent()
        
        // 1. Snowflakes (More realistic: smaller, denser, floaty)
        let snowEmitter = SKEmitterNode()
        snowEmitter.name = "coldParticles"
        snowEmitter.particleTexture = SKTexture(imageNamed: "snowflake")
        snowEmitter.particleBirthRate = 30 // Denser
        snowEmitter.particleLifetime = 7.0
        snowEmitter.particlePositionRange = CGVector(dx: size.width, dy: 100) // Full width
        snowEmitter.emissionAngle = -CGFloat.pi / 2 - 0.2
        snowEmitter.emissionAngleRange = CGFloat.pi / 4
        snowEmitter.particleSpeed = 50
        snowEmitter.particleSpeedRange = 20
        snowEmitter.xAcceleration = -5
        snowEmitter.yAcceleration = -10
        snowEmitter.particleAlpha = 0.9
        snowEmitter.particleAlphaRange = 0.2
        snowEmitter.particleScale = 0.3 // Many small flakes
        snowEmitter.particleScaleRange = 0.2
        snowEmitter.particleRotationSpeed = 1.0
        snowEmitter.position = CGPoint(x: size.width / 2, y: size.height + 50)
        snowEmitter.zPosition = 50 // In front of everything
        addChild(snowEmitter)
        
        // 2. Wind Leaves (Fewer, background accent)
        let leafEmitter = SKEmitterNode()
        leafEmitter.name = "leafParticles"
        leafEmitter.particleSize = CGSize(width: 15, height: 15)
        leafEmitter.particleColor = .orange
        leafEmitter.particleColorBlendFactor = 1.0
        leafEmitter.particleBirthRate = 0.5
        leafEmitter.particleLifetime = 8.0
        leafEmitter.particlePositionRange = CGVector(dx: size.width, dy: 50)
        leafEmitter.emissionAngle = -CGFloat.pi / 2 - 0.5
        leafEmitter.particleSpeed = 40
        leafEmitter.xAcceleration = -20
        leafEmitter.particleRotationSpeed = 2.0
        leafEmitter.particleAlpha = 0.7
        leafEmitter.particleColorSequence = SKKeyframeSequence(keyframeValues: [UIColor.brown, UIColor.orange, UIColor.yellow], times: [0, 0.5, 1])
        leafEmitter.position = CGPoint(x: size.width, y: size.height)
        leafEmitter.zPosition = 49
        addChild(leafEmitter)
        
        // 3. Occasional Rain (More realistic: fast, thin, translucent streaks)
        if Bool.random() {
            let rainEmitter = SKEmitterNode()
            rainEmitter.name = "rainParticles"
            rainEmitter.particleTexture = nil // Use shape
            rainEmitter.particleSize = CGSize(width: 2, height: 45) // Thin streaks
            rainEmitter.particleColor = UIColor(white: 0.9, alpha: 0.35) // Translucent
            rainEmitter.particleBirthRate = 80 // Heavy rain
            rainEmitter.particleLifetime = 2.0
            rainEmitter.particlePositionRange = CGVector(dx: size.width + 100, dy: 0)
            rainEmitter.emissionAngle = -CGFloat.pi / 2 - 0.1 // Slight wind
            rainEmitter.particleSpeed = 900 // Fast!
            rainEmitter.particleSpeedRange = 200
            rainEmitter.position = CGPoint(x: size.width / 2, y: size.height + 100)
            rainEmitter.zPosition = 51 // Most front
            addChild(rainEmitter)
        }
    }
    
    func shiverHarder() {
        guard let sprite = childNode(withName: "ghostSprite") as? SKSpriteNode else { return }
        
        // More intense shivering on wrong answer
        sprite.removeAction(forKey: "shiver")
        sprite.removeAction(forKey: "tremble")
        
        let intenseShiver = SKAction.sequence([
            SKAction.moveBy(x: -10, y: 0, duration: 0.02),
            SKAction.moveBy(x: 20, y: 0, duration: 0.04),
            SKAction.moveBy(x: -10, y: 0, duration: 0.02),
        ])
        
        let shake = SKAction.repeat(intenseShiver, count: 10)
        sprite.run(shake) { [weak self] in
            self?.startShivering()
        }
        
        // Visual feedback for "cold"
        let tintBlue = SKAction.colorize(with: .cyan, colorBlendFactor: 0.5, duration: 0.2)
        let tintBack = SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.5)
        sprite.run(SKAction.sequence([tintBlue, tintBack]))
    }
    
    func addClothingLayer(clothing: ClothingItem) {
        appliedClothing.append(clothing)
        
        // ATTACH TO SPRITE SO IT MOVES TOGETHER
        guard let sprite = childNode(withName: "ghostSprite") as? SKSpriteNode else { return }
        
        // Rebuild all clothing layers to fit the body snugly
        // Remove existing clothing layers
        sprite.children.filter { $0.name?.hasPrefix("clothing_") ?? false }.forEach { $0.removeFromParent() }
        
        let layerCount = appliedClothing.count
        
        // Each clothing type has a different position on the ghost
        for (i, item) in appliedClothing.enumerated() {
            let layer = createClothingLayer(for: item, index: i, total: layerCount, on: sprite)
            layer.alpha = 0
            layer.name = "clothing_\(i)"
            sprite.addChild(layer)
            
            // Appear animation with slight stagger
            layer.run(SKAction.sequence([
                SKAction.wait(forDuration: Double(i) * 0.05),
                SKAction.group([
                    SKAction.fadeIn(withDuration: 0.18),
                    SKAction.scale(to: 1.0, duration: 0.18)
                ])
            ]))
        }
        
        // After 3 clothing items, show pencil-smiley
        if appliedClothing.count >= 3 {
            addPencilSmiley(to: sprite)
        }
        
        // Play pop sound
        playSFX("pop.mp3")
    }
    
    private func createClothingLayer(for item: ClothingItem, index: Int, total: Int, on sprite: SKSpriteNode) -> SKNode {
        let container = SKNode()
        // PNG dosya adları eşlemesi
        func imageName(for item: ClothingItem) -> String? {
            return item.imageName
        }

        if let imgName = imageName(for: item) {
            let texture = SKTexture(imageNamed: imgName)
            let spriteNode = SKSpriteNode(texture: texture)
            spriteNode.zPosition = 20
            // Assets are generated to match the ghost frame exactly
            spriteNode.position = .zero
            spriteNode.size = sprite.size
            container.addChild(spriteNode)
        } else {
            // ...eski vektör çizim kodu buraya alınabilir veya boş bırakılabilir...
        }
        return container
    }
    
    private func addKnitDetails(to node: SKNode, width: CGFloat, height: CGFloat, color: UIColor, stitchSize: CGFloat) {
        // Make knit texture more pronounced and hand-made
        let stitchCount = max(1, Int(width / stitchSize))
        // Use slightly denser rows for visible texture
        let rows = max(1, Int((height) / (stitchSize * 0.8)))
        
        for r in 0..<rows {
            // Offset every other row to simulate looped knitting
            let rowOffset = (r % 2 == 0) ? 0.0 : stitchSize / 2.0
            let yPos = -height/2 + CGFloat(r) * stitchSize * 0.8 + stitchSize * 0.4
            
            for i in 0..<stitchCount {
                var x = -width/2 + CGFloat(i) * stitchSize + stitchSize/2
                x += CGFloat(rowOffset)
                
                // Primary stitch (stronger stroke)
                let stitch = SKShapeNode(path: createStitchPath(size: stitchSize * 0.9))
                stitch.strokeColor = color.lighter(by: 0.12)
                stitch.lineWidth = max(1.2, stitchSize * 0.12)
                stitch.lineCap = .round
                stitch.position = CGPoint(x: x, y: yPos)
                stitch.alpha = 0.85
                stitch.zPosition = 1
                node.addChild(stitch)
                
                // Shadow part of stitch for depth (darker and slightly offset)
                let shadow = SKShapeNode(path: createStitchPath(size: stitchSize * 0.9))
                shadow.strokeColor = color.darker(by: 0.25)
                shadow.lineWidth = max(1.0, stitchSize * 0.11)
                shadow.lineCap = .round
                shadow.position = CGPoint(x: x + 0.6, y: yPos - 1.8)
                shadow.alpha = 0.75
                shadow.zPosition = 0
                node.addChild(shadow)
                
                // Small yarn bump in the center to give a woolly look
                let bumpRadius = max(1.0, stitchSize * 0.12)
                let bump = SKShapeNode(circleOfRadius: bumpRadius)
                bump.fillColor = color.darker(by: 0.15)
                bump.strokeColor = .clear
                bump.position = CGPoint(x: x, y: yPos - stitchSize * 0.06)
                bump.alpha = 0.95
                bump.zPosition = 2
                node.addChild(bump)
                
                // Tiny highlight to imply fiber sheen
                let highlight = SKShapeNode(path: createHighlightArc(size: bumpRadius * 1.6))
                highlight.strokeColor = UIColor.white.withAlphaComponent(0.35)
                highlight.lineWidth = 0.6
                highlight.position = CGPoint(x: x - bumpRadius * 0.25, y: yPos - stitchSize * 0.05)
                highlight.zPosition = 3
                node.addChild(highlight)
            }
        }
    }
    
    private func createStitchPath(size: CGFloat) -> CGPath {
        let path = UIBezierPath()
        // Softer V with slight curve to look like looped yarn
        path.move(to: CGPoint(x: -size/2 + 1, y: size/4))
        path.addQuadCurve(to: CGPoint(x: 0, y: -size/2 + 2), controlPoint: CGPoint(x: -size/4, y: -size/8))
        path.addQuadCurve(to: CGPoint(x: size/2 - 1, y: size/4), controlPoint: CGPoint(x: size/4, y: -size/8))
        return path.cgPath
    }
    
    private func createHighlightArc(size: CGFloat) -> CGPath {
        let path = UIBezierPath()
        path.addArc(withCenter: CGPoint.zero, radius: size/2, startAngle: CGFloat(-0.6), endAngle: CGFloat(0.1), clockwise: true)
        return path.cgPath
    } 
    
    // Add pencil-sketch smiley when 3+ clothing items are applied
    private func addPencilSmiley(to sprite: SKSpriteNode) {
        // Avoid duplicates
        if sprite.childNode(withName: "pencilSmiley") != nil { return }
        let group = SKNode()
        group.name = "pencilSmiley"
        group.position = CGPoint(x: 0, y: -sprite.size.height * 0.1) // Center of body area
        group.zPosition = 100
        
        // Draw head (circle) - thicker stroke for pencil-sketch feel
        let headRadius: CGFloat = 22
        let head = SKShapeNode(circleOfRadius: headRadius)
        head.strokeColor = UIColor.darkGray
        head.lineWidth = 3.5
        head.fillColor = .clear
        head.lineCap = .round
        head.zPosition = 0
        group.addChild(head)
        
        // X Eyes (like in the image)
        let eyeOffsetX: CGFloat = 7
        let eyeOffsetY: CGFloat = 5
        let eyeSize: CGFloat = 5
        
        for dx in [-eyeOffsetX, eyeOffsetX] {
            let xPath = UIBezierPath()
            // Draw X
            xPath.move(to: CGPoint(x: dx - eyeSize/2, y: eyeOffsetY - eyeSize/2))
            xPath.addLine(to: CGPoint(x: dx + eyeSize/2, y: eyeOffsetY + eyeSize/2))
            xPath.move(to: CGPoint(x: dx + eyeSize/2, y: eyeOffsetY - eyeSize/2))
            xPath.addLine(to: CGPoint(x: dx - eyeSize/2, y: eyeOffsetY + eyeSize/2))
            
            let xNode = SKShapeNode(path: xPath.cgPath)
            xNode.strokeColor = UIColor.darkGray
            xNode.lineWidth = 3.0
            xNode.lineCap = .round
            xNode.zPosition = 1
            group.addChild(xNode)
        }
        
        // Big wavy smile curve (like hand-drawn)
        let smilePath = UIBezierPath()
        smilePath.move(to: CGPoint(x: -10, y: -3))
        smilePath.addQuadCurve(to: CGPoint(x: 10, y: -3), controlPoint: CGPoint(x: 0, y: -12))
        let smile = SKShapeNode(path: smilePath.cgPath)
        smile.strokeColor = UIColor.darkGray
        smile.lineWidth = 3.0
        smile.lineCap = .round
        smile.zPosition = 1
        group.addChild(smile)
        
        // Add slight shadow/duplicate for sketchy hand-drawn feel
        let shadow = group.copy() as! SKNode
        shadow.alpha = 0.15
        shadow.position = CGPoint(x: 1.5, y: -1.5)
        shadow.zPosition = -1
        group.addChild(shadow)
        
        sprite.addChild(group)
        
        // Pop animation
        group.setScale(0.5)
        group.alpha = 0
        let pop = SKAction.group([
            SKAction.scale(to: 1.1, duration: 0.2),
            SKAction.fadeAlpha(to: 1.0, duration: 0.2)
        ])
        let settle = SKAction.scale(to: 1.0, duration: 0.1)
        group.run(SKAction.sequence([pop, settle]))
        
        // Auto remove after 3.5s with a fade-out
        group.run(SKAction.sequence([
            SKAction.wait(forDuration: 3.5),
            SKAction.fadeOut(withDuration: 0.35),
            SKAction.removeFromParent()
        ]))
    }
    
    func warmUp() {
        stopShivering()
        updateMouth(happy: true)
        
        guard let sprite = childNode(withName: "ghostSprite") as? SKSpriteNode else { return }
        
        // Warm glow effect using colorize
        let warmColor = SKAction.colorize(with: .orange, colorBlendFactor: 0.3, duration: 0.5)
        sprite.run(warmColor)
        
        // Happy animation - smoother bounce
        let bounceUp = SKAction.moveBy(x: 0, y: 30, duration: 0.3)
        bounceUp.timingMode = .easeOut
        let bounceDown = SKAction.moveBy(x: 0, y: -30, duration: 0.3)
        bounceDown.timingMode = .easeIn
        
        let happySequence = SKAction.sequence([bounceUp, bounceDown])
        sprite.run(SKAction.repeat(happySequence, count: 2))
        
        // Add warm particles
        addWarmParticles()
    }
    
    private func addWarmParticles() {
        for _ in 0..<5 {
            let heart = SKLabelNode(text: "💖")
            heart.fontSize = 20
            heart.position = CGPoint(x: CGFloat.random(in: -30...30), y: 0)
            heart.alpha = 0
            heart.zPosition = 20
            addChild(heart)
            
            let float = SKAction.sequence([
                SKAction.fadeIn(withDuration: 0.2),
                SKAction.group([
                    SKAction.moveBy(x: CGFloat.random(in: -30...30), y: 100, duration: 1.2),
                    SKAction.fadeOut(withDuration: 1.2),
                    SKAction.scale(to: 1.5, duration: 1.2)
                ]),
                SKAction.removeFromParent()
            ])
            float.timingMode = .easeOut
            heart.run(float)
        }
    }
    
    func floatAway() {
        guard let sprite = childNode(withName: "ghostSprite") as? SKSpriteNode else {
            self.removeFromParent()
            return
        }
        
        let floatUp = SKAction.group([
            SKAction.moveBy(x: 0, y: 500, duration: 2.0),
            SKAction.fadeOut(withDuration: 2.0),
            SKAction.scale(to: 0.3, duration: 2.0),
            SKAction.rotate(byAngle: 0.5, duration: 2.0)
        ])
        floatUp.timingMode = .easeIn
        
        sprite.run(floatUp) {
            self.removeFromParent()
        }
    }
    
    func disappearSadly() {
        // For picky ghost when wrong
        let fadeAway = SKAction.group([
            SKAction.fadeOut(withDuration: 0.5),
            SKAction.scale(to: 0.3, duration: 0.5)
        ])
        run(fadeAway) {
            self.removeFromParent()
        }
    }
    
    func freezeToDeath(completion: @escaping () -> Void) {
        // Ghost freezes/dies - timeout animation
        stopShivering()
        
        guard let sprite = childNode(withName: "ghostSprite") as? SKSpriteNode else {
            removeFromParent()
            completion()
            return
        }
        
        // Play freeze/death sound if available
        playSFX("freeze_death.mp3")
        
        // Turn PURPLE and dark
        // Using color blend (might cause border artifacts but requested by user)
        let deathColor = SKAction.colorize(with: .purple, colorBlendFactor: 0.8, duration: 0.5)
        sprite.run(deathColor)
        
        // Shake violently then freeze
        let violentShake = SKAction.sequence([
            SKAction.moveBy(x: -8, y: 0, duration: 0.03),
            SKAction.moveBy(x: 16, y: 0, duration: 0.06),
            SKAction.moveBy(x: -8, y: 0, duration: 0.03)
        ])
        let shakeSequence = SKAction.repeat(violentShake, count: 10)
        
        // Ice crystals appear (optional, keeping for effect)
        let addIce = SKAction.run { [weak self] in
            guard let self = self else { return }
            for _ in 0..<5 {
                let ice = SKLabelNode(text: "☠️")
                ice.fontSize = CGFloat.random(in: 20...30)
                ice.position = CGPoint(x: CGFloat.random(in: -50...50), y: CGFloat.random(in: 40...80))
                ice.alpha = 0
                ice.zPosition = 15
                self.addChild(ice)
                ice.run(SKAction.sequence([SKAction.fadeIn(withDuration: 0.2), SKAction.moveBy(x: 0, y: 20, duration: 1.0)]))
            }
        }
        
        sprite.run(SKAction.sequence([
            shakeSequence,
            addIce,
            SKAction.wait(forDuration: 1.5), // Wait to show the dead face
            SKAction.fadeOut(withDuration: 0.2)
        ])) {
            self.removeFromParent()
            completion()
        }
    }
    
    private func addDeadFace(to sprite: SKSpriteNode) {
        let size = sprite.size
        
        // X eyes (Larger for "dead" effect)
        let eyeSize = size.width * 0.12
        let eyeOffset = size.width * 0.16
        let eyeY = size.height * 0.08
        
        func createXEye() -> SKShapeNode {
            let xNode = SKShapeNode()
            let p = UIBezierPath()
            p.move(to: CGPoint(x: -eyeSize/2, y: -eyeSize/2))
            p.addLine(to: CGPoint(x: eyeSize/2, y: eyeSize/2))
            p.move(to: CGPoint(x: eyeSize/2, y: -eyeSize/2))
            p.addLine(to: CGPoint(x: -eyeSize/2, y: eyeSize/2))
            xNode.path = p.cgPath
            xNode.strokeColor = .black
            xNode.lineWidth = 6
            xNode.lineCap = .round
            return xNode
        }
        
        let leftX = createXEye()
        leftX.position = CGPoint(x: -eyeOffset, y: eyeY)
        leftX.zPosition = 30
        sprite.addChild(leftX)
        
        let rightX = createXEye()
        rightX.position = CGPoint(x: eyeOffset, y: eyeY)
        rightX.zPosition = 30
        sprite.addChild(rightX)
    }
}

// MARK: - Game Scene
class GameScene: SKScene {
    
    // MARK: - Properties
    private var gameState: GameState = .menu
    private var currentGhost: GhostNode?
    private var clothingItems: [ClothingItemNode] = []  // Changed from yarnBalls
    private var targetPattern: [ClothingItem] = []      // Changed from [YarnColor]
    private var currentPatternIndex = 0
    private var selectedClothing: ClothingItemNode?     // Changed from selectedYarn
    
    private var score = 0
    private var level = 1
    private var ghostsWarmed = 0
    private var combo = 0
    
    // UI Nodes
    private var scoreLabel: SKLabelNode!
    private var levelLabel: SKLabelNode!
    private var comboLabel: SKLabelNode!
    private var patternDisplay: SKNode!
    private var startButton: SKNode?
    private var titleLabel: SKLabelNode?
    
    // Timer
    private var timerLabel: SKLabelNode!
    private var timerBar: SKShapeNode!
    private var timeRemaining: TimeInterval = 40.0
    private var maxTime: TimeInterval = 40.0
    private var lastUpdateTime: TimeInterval = 0
    private var backgroundMusicPlayer: AVAudioPlayer?
    private var windSoundPlayer: AVAudioPlayer?
    
    // Pause System
    private var isGamePaused = false
    private var pauseOverlay: SKNode?
    private var pauseButton: SKNode?
    
    // Difficulty System
    private var speedMultiplier: CGFloat = 1.0
    private var hasFakeYarns = false
    private var hasLockedYarns = false
    private var hasTimedYarns = false
    private var fakeYarnCount = 0
    private var lockedYarnIndices: Set<Int> = []
    private var timedYarnDeadlines: [ClothingItemNode: TimeInterval] = [:]  // Changed from YarnBallNode
    
    // Collection tracking
    private var usedColorsThisRound: Set<String> = []
    private var maxComboThisRound = 0
    
    // Haptic feedback generator
    private let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let selectionGenerator = UISelectionFeedbackGenerator()
    private let notificationGenerator = UINotificationFeedbackGenerator()
    
    // MARK: - Scene Lifecycle
    override func didMove(to view: SKView) {
        backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.2, alpha: 1.0)
        
        setupBackground()
        setupUI()
        showMenu()
        
        // Initialize audio session
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set audio session category: \(error)")
        }
        
        // Start audio
        playWindAmbience()
        playBackgroundMusic()
    }
    
    // MARK: - Audio Handling
    private func playBackgroundMusic() {
        guard let url = Bundle.main.url(forResource: "game_music", withExtension: "mp3") else { return }
        
        do {
            backgroundMusicPlayer = try AVAudioPlayer(contentsOf: url)
            backgroundMusicPlayer?.numberOfLoops = -1 // Loop forever
            
            let settings = CollectionManager.shared.settings
            backgroundMusicPlayer?.volume = settings.musicEnabled ? settings.musicVolume : 0.0
            
            if settings.musicEnabled {
                backgroundMusicPlayer?.play()
            }
        } catch {
            print("Could not create audio player for music: \(error)")
        }
    }
    
    private func playWindAmbience() {
        guard let url = Bundle.main.url(forResource: "wind_ambience", withExtension: "mp3") else { return }
        
        do {
            windSoundPlayer = try AVAudioPlayer(contentsOf: url)
            windSoundPlayer?.numberOfLoops = -1 // Loop forever
            
            let settings = CollectionManager.shared.settings
            windSoundPlayer?.volume = settings.soundEffectsEnabled ? 0.3 : 0.0
            
            if settings.soundEffectsEnabled {
                windSoundPlayer?.play()
            }
        } catch {
            print("Could not create audio player for wind: \(error)")
        }
    }
    
    // MARK: - Setup
    private func setupBackground() {
        // Night sky gradient
        let gradientNode = SKSpriteNode(color: .clear, size: size)
        gradientNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        gradientNode.zPosition = -10
        
        // Stars
        for _ in 0..<50 {
            let star = SKShapeNode(circleOfRadius: CGFloat.random(in: 1...3))
            star.fillColor = .white
            star.position = CGPoint(x: CGFloat.random(in: 0...size.width),
                                    y: CGFloat.random(in: size.height * 0.5...size.height))
            star.alpha = CGFloat.random(in: 0.3...1.0)
            star.zPosition = -5
            addChild(star)
            
            // Twinkle animation
            let twinkle = SKAction.sequence([
                SKAction.fadeAlpha(to: 0.3, duration: Double.random(in: 1...3)),
                SKAction.fadeAlpha(to: 1.0, duration: Double.random(in: 1...3))
            ])
            star.run(SKAction.repeatForever(twinkle))
        }
        
        // Moon
        let moon = SKShapeNode(circleOfRadius: 40)
        moon.fillColor = UIColor(red: 1.0, green: 0.98, blue: 0.9, alpha: 1.0)
        moon.strokeColor = UIColor(red: 1.0, green: 0.95, blue: 0.8, alpha: 1.0)
        moon.glowWidth = 15
        moon.position = CGPoint(x: size.width - 80, y: size.height - 100)
        moon.zPosition = -5
        addChild(moon)
    }
    
    private func setupUI() {
        // Score
        scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        scoreLabel.fontSize = 24
        scoreLabel.fontColor = .white
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x: 20, y: size.height - 50)
        scoreLabel.zPosition = 50
        scoreLabel.text = "Score: 0"
        addChild(scoreLabel)
        
        // Level
        levelLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
        levelLabel.fontSize = 18
        levelLabel.fontColor = UIColor(white: 0.8, alpha: 1.0)
        levelLabel.horizontalAlignmentMode = .left
        levelLabel.position = CGPoint(x: 20, y: size.height - 80)
        levelLabel.zPosition = 50
        levelLabel.text = "Level: 1"
        addChild(levelLabel)
        
        // Combo
        comboLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        comboLabel.fontSize = 20
        comboLabel.fontColor = ClothingColor.yellow.color
        comboLabel.horizontalAlignmentMode = .right
        comboLabel.position = CGPoint(x: size.width - 20, y: size.height - 50)
        comboLabel.zPosition = 50
        comboLabel.text = ""
        addChild(comboLabel)
        
        // Pattern display container
        patternDisplay = SKNode()
        patternDisplay.position = CGPoint(x: size.width / 2, y: size.height - 140)
        patternDisplay.zPosition = 50
        addChild(patternDisplay)
    }
    
    // MARK: - Menu
    private func showMenu() {
        gameState = .menu
        
        // Title
        titleLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        titleLabel?.fontSize = 36
        titleLabel?.fontColor = .white
        titleLabel?.text = "👻 Shivering Ghosts"
        titleLabel?.position = CGPoint(x: size.width / 2, y: size.height * 0.7)
        titleLabel?.zPosition = 100
        addChild(titleLabel!)
        
        // Subtitle
        let subtitle = SKLabelNode(fontNamed: "AvenirNext-Regular")
        subtitle.fontSize = 16
        subtitle.fontColor = UIColor(white: 0.7, alpha: 1.0)
        subtitle.text = "\"Not scary. Just a little cold.\""
        subtitle.position = CGPoint(x: size.width / 2, y: size.height * 0.65)
        subtitle.zPosition = 100
        subtitle.name = "subtitle"
        addChild(subtitle)
        
        // Start button
        let buttonBg = SKShapeNode(rectOf: CGSize(width: 200, height: 60), cornerRadius: 30)
        buttonBg.fillColor = ClothingColor.green.color
        buttonBg.strokeColor = ClothingColor.green.color.darker(by: 0.2)
        buttonBg.lineWidth = 3
        buttonBg.position = CGPoint(x: size.width / 2, y: size.height * 0.4)
        buttonBg.zPosition = 100
        buttonBg.name = "startButton"
        
        let buttonLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        buttonLabel.fontSize = 24
        buttonLabel.fontColor = .white
        buttonLabel.text = "▶️ START"
        buttonLabel.verticalAlignmentMode = .center
        buttonLabel.zPosition = 101
        buttonBg.addChild(buttonLabel)
        
        addChild(buttonBg)
        startButton = buttonBg
        
        // Pulse animation
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.05, duration: 0.5),
            SKAction.scale(to: 1.0, duration: 0.5)
        ])
        buttonBg.run(SKAction.repeatForever(pulse))
        
        // Settings button
        let settingsButton = SKShapeNode(circleOfRadius: 25)
        settingsButton.fillColor = UIColor(white: 0.3, alpha: 0.8)
        settingsButton.strokeColor = .white
        settingsButton.lineWidth = 2
        settingsButton.position = CGPoint(x: size.width - 40, y: size.height - 50)
        settingsButton.zPosition = 100
        settingsButton.name = "settingsButton"
        
        let settingsIcon = SKLabelNode(text: "⚙️")
        settingsIcon.fontSize = 24
        settingsIcon.verticalAlignmentMode = .center
        settingsButton.addChild(settingsIcon)
        addChild(settingsButton)
        
        // Collection button
        let collectionButton = SKShapeNode(rectOf: CGSize(width: 160, height: 45), cornerRadius: 22)
        collectionButton.fillColor = ClothingColor.purple.color
        collectionButton.strokeColor = ClothingColor.purple.color.darker(by: 0.2)
        collectionButton.lineWidth = 2
        collectionButton.position = CGPoint(x: size.width / 2, y: size.height * 0.28)
        collectionButton.zPosition = 100
        collectionButton.name = "collectionButton"
        
        let collectionLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        collectionLabel.fontSize = 16
        collectionLabel.fontColor = .white
        collectionLabel.text = "👕 COLLECTION"
        collectionLabel.verticalAlignmentMode = .center
        collectionButton.addChild(collectionLabel)
        addChild(collectionButton)
        
        // High score display
        let highScore = CollectionManager.shared.stats.highScore
        if highScore > 0 {
            let highScoreLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
            highScoreLabel.fontSize = 14
            highScoreLabel.fontColor = ClothingColor.yellow.color
            highScoreLabel.text = "🏆 High Score: \(highScore)"
            highScoreLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.2)
            highScoreLabel.zPosition = 100
            highScoreLabel.name = "highScoreLabel"
            addChild(highScoreLabel)
        }
        
        // Demo ghost
        let demoGhost = GhostNode(type: .standard, size: CGSize(width: 100, height: 120))
        demoGhost.position = CGPoint(x: size.width / 2, y: size.height * 0.55)
        demoGhost.name = "demoGhost"
        demoGhost.zPosition = 99
        addChild(demoGhost)
    }
    
    private func hideMenu() {
        titleLabel?.run(SKAction.fadeOut(withDuration: 0.3)) {
            self.titleLabel?.removeFromParent()
        }
        childNode(withName: "subtitle")?.run(SKAction.fadeOut(withDuration: 0.3)) {
            self.childNode(withName: "subtitle")?.removeFromParent()
        }
        startButton?.run(SKAction.fadeOut(withDuration: 0.3)) {
            self.startButton?.removeFromParent()
        }
        childNode(withName: "demoGhost")?.run(SKAction.fadeOut(withDuration: 0.3)) {
            self.childNode(withName: "demoGhost")?.removeFromParent()
        }
        childNode(withName: "settingsButton")?.run(SKAction.fadeOut(withDuration: 0.3)) {
            self.childNode(withName: "settingsButton")?.removeFromParent()
        }
        childNode(withName: "collectionButton")?.run(SKAction.fadeOut(withDuration: 0.3)) {
            self.childNode(withName: "collectionButton")?.removeFromParent()
        }
        childNode(withName: "highScoreLabel")?.run(SKAction.fadeOut(withDuration: 0.3)) {
            self.childNode(withName: "highScoreLabel")?.removeFromParent()
        }
    }
    
    // MARK: - Game Logic
    private func startGame() {
        hideMenu()
        cleanupGameOver()
        
        score = 0
        level = 1
        ghostsWarmed = 0
        combo = 0
        timeRemaining = maxTime
        lastUpdateTime = 0
        
        // Reset difficulty modifiers
        speedMultiplier = 1.0
        hasFakeYarns = false
        hasLockedYarns = false
        hasTimedYarns = false
        fakeYarnCount = 0
        lockedYarnIndices.removeAll()
        timedYarnDeadlines.removeAll()
        usedColorsThisRound.removeAll()
        maxComboThisRound = 0
        
        updateUI()
        setupPauseButton()
        
        gameState = .playing
        
        // Prepare haptic
        impactGenerator.prepare()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.spawnNewGhost()
        }
    }
    
    private func setupPauseButton() {
        pauseButton?.removeFromParent()
        
        let button = SKShapeNode(circleOfRadius: 20)
        button.fillColor = UIColor(white: 0.2, alpha: 0.8)
        button.strokeColor = .white
        button.lineWidth = 2
        button.position = CGPoint(x: size.width - 35, y: size.height - 50)
        button.zPosition = 150
        button.name = "pauseButton"
        
        let icon = SKLabelNode(text: "⏸️")
        icon.fontSize = 18
        icon.verticalAlignmentMode = .center
        button.addChild(icon)
        
        addChild(button)
        pauseButton = button
    }
    
    private func cleanupGameOver() {
        // Remove all game over UI elements
        childNode(withName: "gameOverOverlay")?.removeFromParent()
        enumerateChildNodes(withName: "retryButton") { node, _ in node.removeFromParent() }
        
        // Remove any leftover labels from game over
        children.filter { $0 is SKLabelNode && $0.zPosition == 201 }.forEach { $0.removeFromParent() }
        children.filter { $0 is SKShapeNode && $0.zPosition >= 200 }.forEach { $0.removeFromParent() }
        
        // Remove timer UI
        timerLabel?.removeFromParent()
        timerBar?.removeFromParent()
        childNode(withName: "timerBarBg")?.removeFromParent()
    }
    
    private func spawnNewGhost() {
        // Determine ghost type based on level (elder type removed)
        let ghostType: GhostType
        let rand = Int.random(in: 1...100)
        
        if level >= 5 && rand <= 15 {
            ghostType = .rare
        } else if level >= 3 && rand <= 30 {
            ghostType = .picky
        } else if level >= 2 && rand <= 40 {
            ghostType = .baby
        } else {
            ghostType = .standard
        }
        
        // Create ghost with type-specific size
        let baseSize = CGSize(width: 270, height: 340)
        let scaledSize = CGSize(width: baseSize.width * ghostType.sizeScale, 
                                height: baseSize.height * ghostType.sizeScale)
        let ghost = GhostNode(type: ghostType, size: scaledSize)
        ghost.position = CGPoint(x: size.width / 2, y: size.height * 0.55)
        ghost.alpha = 0
        ghost.setScale(0.5)
        addChild(ghost)
        currentGhost = ghost
        
        // Entrance animation
        ghost.run(SKAction.group([
            SKAction.fadeIn(withDuration: 0.3),
            SKAction.scale(to: 1.0, duration: 0.3)
        ]))
        
        // Show ghost type
        showGhostTypeLabel(ghostType)
        
        // Generate pattern
        generatePattern(for: ghostType)
        displayPattern()
        
        // Spawn yarn balls
        spawnClothingItems()
        
        currentPatternIndex = 0
        
        // Start timer
        timeRemaining = maxTime
        setupTimerUI()
    }
    
    private func setupTimerUI() {
        // Remove old timer UI
        timerLabel?.removeFromParent()
        timerBar?.removeFromParent()
        
        // Timer label
        timerLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        timerLabel.fontSize = 20
        timerLabel.fontColor = .white
        timerLabel.text = "⏱ 40"
        timerLabel.position = CGPoint(x: size.width / 2, y: size.height - 50)
        timerLabel.zPosition = 50
        addChild(timerLabel)
        
        // Timer bar background
        let barWidth: CGFloat = 200
        let barHeight: CGFloat = 10
        let barBg = SKShapeNode(rectOf: CGSize(width: barWidth, height: barHeight), cornerRadius: 5)
        barBg.fillColor = UIColor(white: 0.3, alpha: 0.5)
        barBg.strokeColor = .clear
        barBg.position = CGPoint(x: size.width / 2, y: size.height - 75)
        barBg.zPosition = 49
        barBg.name = "timerBarBg"
        addChild(barBg)
        
        // Timer bar fill
        timerBar = SKShapeNode(rectOf: CGSize(width: barWidth, height: barHeight), cornerRadius: 5)
        timerBar.fillColor = ClothingColor.green.color
        timerBar.strokeColor = .clear
        timerBar.position = CGPoint(x: size.width / 2, y: size.height - 75)
        timerBar.zPosition = 50
        addChild(timerBar)
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard gameState == .playing && !isGamePaused else {
            lastUpdateTime = currentTime
            return
        }
        
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }
        
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        // Update timer
        timeRemaining -= deltaTime
        
        if timeRemaining <= 0 {
            timeRemaining = 0
            ghostTimedOut()
        }
        
        // Update timer UI
        updateTimerUI()
    }
    
    private func updateTimerUI() {
        let seconds = Int(ceil(timeRemaining))
        timerLabel?.text = "⏱ \(seconds)"
        
        // Update bar width
        let progress = CGFloat(timeRemaining / maxTime)
        let barWidth: CGFloat = 200 * progress
        
        timerBar?.removeFromParent()
        timerBar = SKShapeNode(rectOf: CGSize(width: barWidth, height: 10), cornerRadius: 5)
        
        // Color changes based on time
        if timeRemaining > 10 {
            timerBar.fillColor = ClothingColor.green.color
        } else if timeRemaining > 5 {
            timerBar.fillColor = ClothingColor.yellow.color
        } else {
            timerBar.fillColor = ClothingColor.red.color
            // Pulse effect when low
            timerLabel?.run(SKAction.sequence([
                SKAction.scale(to: 1.1, duration: 0.1),
                SKAction.scale(to: 1.0, duration: 0.1)
            ]), withKey: "pulse")
        }
        
        timerBar.strokeColor = .clear
        timerBar.position = CGPoint(x: size.width / 2 - (200 - barWidth) / 2, y: size.height - 75)
        timerBar.zPosition = 50
        addChild(timerBar)
    }
    
    private func ghostTimedOut() {
        gameState = .failure
        
        // Play timeout sound if available
        playSFX("timeout.mp3")
        
        // Ghost freezes to death
        currentGhost?.freezeToDeath { [weak self] in
            self?.showGameOver(reason: "Ghost froze to death! 🥶")
        }
        
        // Clear clothing items
        for item in clothingItems {
            item.run(SKAction.sequence([
                SKAction.fadeOut(withDuration: 0.3),
                SKAction.removeFromParent()
            ]))
        }
        clothingItems.removeAll()
        
        // Hide timer
        timerLabel?.run(SKAction.fadeOut(withDuration: 0.3))
        timerBar?.run(SKAction.fadeOut(withDuration: 0.3))
        childNode(withName: "timerBarBg")?.run(SKAction.fadeOut(withDuration: 0.3))
    }
    
    private func showGameOver(reason: String) {
        gameState = .gameOver
        
        // Dark overlay
        let overlay = SKShapeNode(rectOf: size)
        overlay.fillColor = UIColor(white: 0, alpha: 0.7)
        overlay.position = CGPoint(x: size.width / 2, y: size.height / 2)
        overlay.zPosition = 200
        overlay.alpha = 0
        overlay.name = "gameOverOverlay"
        addChild(overlay)
        overlay.run(SKAction.fadeIn(withDuration: 0.3))
        
        // Game Over text
        let gameOverLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        gameOverLabel.fontSize = 36
        gameOverLabel.fontColor = .white
        gameOverLabel.text = "💀 GAME OVER"
        gameOverLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.6)
        gameOverLabel.zPosition = 201
        gameOverLabel.alpha = 0
        addChild(gameOverLabel)
        gameOverLabel.run(SKAction.fadeIn(withDuration: 0.3))
        
        // Reason
        let reasonLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
        reasonLabel.fontSize = 18
        reasonLabel.fontColor = UIColor(white: 0.8, alpha: 1.0)
        reasonLabel.text = reason
        reasonLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.52)
        reasonLabel.zPosition = 201
        addChild(reasonLabel)
        
        // Score
        let finalScoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        finalScoreLabel.fontSize = 24
        finalScoreLabel.fontColor = ClothingColor.yellow.color
        finalScoreLabel.text = "Score: \(score)"
        finalScoreLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.45)
        finalScoreLabel.zPosition = 201
        addChild(finalScoreLabel)
        
        // Retry button
        let retryButton = SKShapeNode(rectOf: CGSize(width: 180, height: 50), cornerRadius: 25)
        retryButton.fillColor = ClothingColor.green.color
        retryButton.strokeColor = ClothingColor.green.color.darker(by: 0.2)
        retryButton.position = CGPoint(x: size.width / 2, y: size.height * 0.3)
        retryButton.zPosition = 201
        retryButton.name = "retryButton"
        addChild(retryButton)
        
        let retryLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        retryLabel.fontSize = 20
        retryLabel.fontColor = .white
        retryLabel.text = "🔄 PLAY AGAIN"
        retryLabel.verticalAlignmentMode = .center
        retryButton.addChild(retryLabel)
        
        // Pulse animation
        retryButton.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.scale(to: 1.05, duration: 0.5),
            SKAction.scale(to: 1.0, duration: 0.5)
        ])))
    }
    
    private func showGhostTypeLabel(_ type: GhostType) {
        let typeLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
        typeLabel.fontSize = 16
        typeLabel.fontColor = UIColor(white: 0.9, alpha: 1.0)
        typeLabel.text = type.name
        typeLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.72)
        typeLabel.alpha = 0
        addChild(typeLabel)
        
        typeLabel.run(SKAction.sequence([
            SKAction.fadeIn(withDuration: 0.2),
            SKAction.wait(forDuration: 1.5),
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.removeFromParent()
        ]))
    }
    
    private func generatePattern(for ghostType: GhostType) {
        targetPattern.removeAll()
        
        // Pick one of each type
        let hats = [
            ClothingItem(type: .hat, color: .red),
            ClothingItem(type: .hat, color: .blue),
            ClothingItem(type: .hat, color: .purple)
        ]
        
        let scarves = [
            ClothingItem(type: .scarf, color: .red),
            ClothingItem(type: .scarf, color: .blue),
            ClothingItem(type: .scarf, color: .green)
        ]
        
        let sweaters = [
            ClothingItem(type: .sweater, color: .purple),
            ClothingItem(type: .sweater, color: .orange),
            ClothingItem(type: .sweater, color: .green)
        ]
        
        if let hat = hats.randomElement(),
           let scarf = scarves.randomElement(),
           let sweater = sweaters.randomElement() {
            targetPattern = [hat, scarf, sweater]
        }
    }
    
    private func displayPattern() {
        // Clear previous pattern
        patternDisplay.removeAllChildren()
        
        let spacing: CGFloat = 160 // Increased spacing for 150 size icons
        let startX = -CGFloat(targetPattern.count - 1) * spacing / 2
        
        for (index, item) in targetPattern.enumerated() {
            // Create container for clothing item display
            let container = SKNode()
            container.position = CGPoint(x: startX + CGFloat(index) * spacing, y: 0)
            container.name = "pattern_\(index)"
            
            let size: CGFloat = 150 // Set to 150 as requested
            
            // Clothing icon
            if let imgName = item.imageName {
                let texture = SKTexture(imageNamed: imgName)
                let iconSprite = SKSpriteNode(texture: texture)
                // Maintain aspect ratio for the icons
                let aspectRatio = texture.size().width / texture.size().height
                iconSprite.size = CGSize(width: size * aspectRatio, height: size)
                
                // Visual Balancing - Center the items visually
                switch item.type {
                case .hat:
                    iconSprite.position.y = -size * 0.2 // Move down
                case .scarf:
                    iconSprite.position.y = -size * 0.1 // Move down slightly
                case .sweater:
                    iconSprite.position.y = size * 0.1 // Move up slightly
                }
                
                container.addChild(iconSprite)
            } else {
                let icon = SKLabelNode(text: item.type.emoji)
                icon.fontSize = size * 0.5
                icon.verticalAlignmentMode = .center
                container.addChild(icon)
            }
            
            patternDisplay.addChild(container)
            
            // Animate entrance
            container.alpha = 0
            container.setScale(0.5)
            container.run(SKAction.sequence([
                SKAction.wait(forDuration: Double(index) * 0.1),
                SKAction.group([
                    SKAction.fadeIn(withDuration: 0.2),
                    SKAction.scale(to: 1.0, duration: 0.2)
                ])
            ]))
        }
        
        // Add indicator arrow
        updatePatternIndicator()
    }
    
    private func updatePatternIndicator() {
        patternDisplay.childNode(withName: "indicator")?.removeFromParent()
        
        guard currentPatternIndex < targetPattern.count else { return }
        
        let spacing: CGFloat = 70  // Match displayPattern spacing
        let startX = -CGFloat(targetPattern.count - 1) * spacing / 2
        
        let indicator = SKLabelNode(text: "▼")
        indicator.fontSize = 20
        indicator.fontColor = .white
        indicator.position = CGPoint(x: startX + CGFloat(currentPatternIndex) * spacing, y: 30)
        indicator.name = "indicator"
        patternDisplay.addChild(indicator)
        
        // Bounce animation
        let bounce = SKAction.sequence([
            SKAction.moveBy(x: 0, y: -5, duration: 0.3),
            SKAction.moveBy(x: 0, y: 5, duration: 0.3)
        ])
        indicator.run(SKAction.repeatForever(bounce))
    }
    
    private func spawnClothingItems() {
        // Clear previous items
        clothingItems.forEach { $0.removeFromParent() }
        clothingItems.removeAll()
        
        // Start with unique items from the pattern
        var itemsToSpawn: [ClothingItem] = []
        for item in targetPattern {
            if !itemsToSpawn.contains(item) {
                itemsToSpawn.append(item)
            }
        }
        
        // Pool of available assets
        var pool = [
            ClothingItem(type: .hat, color: .red), ClothingItem(type: .hat, color: .blue), ClothingItem(type: .hat, color: .purple),
            ClothingItem(type: .scarf, color: .red), ClothingItem(type: .scarf, color: .blue), ClothingItem(type: .scarf, color: .green),
            ClothingItem(type: .sweater, color: .purple), ClothingItem(type: .sweater, color: .orange), ClothingItem(type: .sweater, color: .green)
        ]
        pool.shuffle()
        
        // Fill up to 5 unique items
        for poolItem in pool {
            if itemsToSpawn.count >= 5 { break }
            if !itemsToSpawn.contains(poolItem) {
                itemsToSpawn.append(poolItem)
            }
        }
        
        itemsToSpawn.shuffle()
        
        let count = itemsToSpawn.count
        // Adaptive sizing and spacing
        var itemSize: CGFloat
        var spacing: CGFloat
        switch count {
        case 6:
            itemSize = 55
            spacing = 70
        case 5:
            itemSize = 58
            spacing = 75
        case 4:
            itemSize = 60
            spacing = 80
        default:
            itemSize = 150 // Set to 150 as requested
            spacing = 170
        }

        // Ensure it fits within screen width -- DISABLED scaling to force large size
        // let totalWidth = CGFloat(max(0, count - 1)) * spacing + itemSize
        // let maxWidth = size.width * 0.9
        /*
        if totalWidth > maxWidth {
            let scale = maxWidth / totalWidth
            itemSize *= scale
            spacing *= scale
        }
        */

        let startX = size.width / 2 - CGFloat(count - 1) * spacing / 2
        let itemY = size.height * 0.15
        
        for (index, clothing) in itemsToSpawn.enumerated() {
            let clothingNode = ClothingItemNode(clothing: clothing, size: itemSize)
            let xPos = startX + CGFloat(index) * spacing
            clothingNode.position = CGPoint(x: xPos, y: itemY)
            clothingNode.originalPosition = clothingNode.position
            clothingNode.zPosition = 10
            clothingNode.alpha = 0
            clothingNode.setScale(1.0)
            addChild(clothingNode)
            clothingItems.append(clothingNode)
            
            // Animate entrance (fade in)
            clothingNode.run(SKAction.sequence([
                SKAction.wait(forDuration: Double(index) * 0.05),
                SKAction.fadeIn(withDuration: 0.2)
            ]))
        }
    }
    
    private func checkClothingMatch(_ clothing: ClothingItemNode) {
        guard currentPatternIndex < targetPattern.count else { return }
        
        let expectedItem = targetPattern[currentPatternIndex]
        
        // Check if both type AND color match
        if clothing.clothing.type == expectedItem.type && clothing.clothing.color == expectedItem.color {
            // Correct!
            handleCorrectMatch(clothing)
        } else {
            // Wrong!
            handleWrongMatch(clothing)
        }
    }
    
    private func handleCorrectMatch(_ clothing: ClothingItemNode) {
        // Haptic feedback
        triggerHaptic(.success)
        
        // Add to ghost's clothing
        currentGhost?.addClothingLayer(clothing: clothing.clothing)
        
        // Play correct match sound
        playSFX("correct_match.mp3")
        
        // Mark pattern as complete
        if let patternContainer = patternDisplay.childNode(withName: "pattern_\(currentPatternIndex)") {
            patternContainer.run(SKAction.sequence([
                SKAction.scale(to: 1.3, duration: 0.1),
                SKAction.scale(to: 1.0, duration: 0.1)
            ]))
            
            // Add checkmark
            let check = SKLabelNode(text: "✓")
            check.fontSize = 25
            check.fontColor = .white
            check.zPosition = 10
            patternContainer.addChild(check)
        }
        
        // Remove clothing item
        clothing.run(SKAction.sequence([
            SKAction.scale(to: 0, duration: 0.2),
            SKAction.removeFromParent()
        ]))
        clothingItems.removeAll { $0 == clothing }
        
        // Update combo
        combo += 1
        if combo > maxComboThisRound {
            maxComboThisRound = combo
        }
        updateComboDisplay()
        
        // Add score with ghost type multiplier
        let basePoints = 10 * combo
        let multiplier = currentGhost?.ghostType.scoreMultiplier ?? 1.0
        let points = Int(Double(basePoints) * multiplier)
        score += points
        showFloatingScore(points, at: clothing.position)
        
        // Move to next
        currentPatternIndex += 1
        updatePatternIndicator()
        
        // Check if pattern complete
        if currentPatternIndex >= targetPattern.count {
            handleGhostWarmed()
        }
        
        updateUI()
    }
    
    private func handleWrongMatch(_ clothing: ClothingItemNode) {
        guard let ghost = currentGhost else { return }
        
        // Haptic feedback
        triggerHaptic(.error)
        
        // Play wrong match sound
        playSFX("wrong_match.mp3")
        
        // Reset combo
        combo = 0
        updateComboDisplay()
        
        // Ghost reaction
        ghost.shiverHarder()
        
        // Return clothing item
        clothing.returnToOriginal()
        
        // Show X
        let wrongLabel = SKLabelNode(text: "❌")
        wrongLabel.fontSize = 40
        wrongLabel.position = clothing.position
        wrongLabel.position.y += 50
        addChild(wrongLabel)
        
        wrongLabel.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.5),
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.removeFromParent()
        ]))
        
        // Check if picky ghost
        if ghost.ghostType == .picky {
            handleGameOver()
        }
    }
    
    private func handleGhostWarmed() {
        guard let ghost = currentGhost else { return }
        
        gameState = .success
        ghostsWarmed += 1
        
        // Play happy ghost sound ("Wuuu~")
        playSFX("ghost_happy.mp3")
        
        // Bonus for completion with ghost type multiplier
        let baseBonus = 50 * level
        let multiplier = ghost.ghostType.scoreMultiplier
        let bonus = Int(Double(baseBonus) * multiplier)
        score += bonus
        showFloatingScore(bonus, at: ghost.position, isBonus: true)
        
        // Ghost warm up animation
        ghost.warmUp()
        
        // Show success message based on ghost type
        let successMessage: String
        switch ghost.ghostType {
        case .baby:
            successMessage = "👶 Baby is happy!"
        case .picky:
            successMessage = "✨ Perfect!"
        case .rare:
            successMessage = "🌟 AMAZING!"
        default:
            successMessage = "🎉 Awesome!"
        }
        
        let successLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        successLabel.fontSize = 28
        successLabel.fontColor = ClothingColor.yellow.color
        successLabel.text = successMessage
        successLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.8)
        addChild(successLabel)
        
        successLabel.run(SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.2),
            SKAction.scale(to: 1.0, duration: 0.2),
            SKAction.wait(forDuration: 1.0),
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.removeFromParent()
        ]))
        
        // Float ghost away
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            ghost.floatAway()
            self.clearYarnBalls()
            self.clearPattern()
            
            // Level up check
            if self.ghostsWarmed % 3 == 0 {
                self.levelUp()
            }
            
            // Spawn next ghost
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.gameState = .playing
                self.spawnNewGhost()
            }
        }
        
        updateUI()
    }
    
    private func levelUp() {
        level += 1
        
        // Update difficulty settings
        updateDifficultyForLevel()
        
        // Haptic feedback
        triggerHaptic(.success)
        
        let levelUpLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        levelUpLabel.fontSize = 32
        levelUpLabel.fontColor = ClothingColor.purple.color
        levelUpLabel.text = "⬆️ Seviye \(level)!"
        levelUpLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        levelUpLabel.zPosition = 200
        addChild(levelUpLabel)
        
        levelUpLabel.run(SKAction.sequence([
            SKAction.group([
                SKAction.scale(to: 1.5, duration: 0.3),
                SKAction.fadeIn(withDuration: 0.1)
            ]),
            SKAction.wait(forDuration: 1.0),
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.removeFromParent()
        ]))
        
        updateUI()
    }
    
    private func handleGameOver() {
        gameState = .gameOver
        
        currentGhost?.disappearSadly()
        clearYarnBalls()
        clearPattern()
        
        // Show game over UI
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showGameOver()
        }
    }
    
    private func showGameOver() {
        let overlay = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height))
        overlay.fillColor = UIColor(white: 0, alpha: 0.7)
        overlay.position = CGPoint(x: size.width / 2, y: size.height / 2)
        overlay.zPosition = 150
        overlay.name = "gameOverOverlay"
        addChild(overlay)
        
        let gameOverLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        gameOverLabel.fontSize = 36
        gameOverLabel.fontColor = .white
        gameOverLabel.text = "Oyun Bitti!"
        gameOverLabel.position = CGPoint(x: 0, y: 80)
        overlay.addChild(gameOverLabel)
        
        let scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
        scoreLabel.fontSize = 24
        scoreLabel.fontColor = ClothingColor.yellow.color
        scoreLabel.text = "Skor: \(score)"
        scoreLabel.position = CGPoint(x: 0, y: 30)
        overlay.addChild(scoreLabel)
        
        let ghostsLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
        ghostsLabel.fontSize = 18
        ghostsLabel.fontColor = UIColor(white: 0.8, alpha: 1.0)
        ghostsLabel.text = "Ghosts Warmed: \(ghostsWarmed)"
        ghostsLabel.position = CGPoint(x: 0, y: -10)
        overlay.addChild(ghostsLabel)
        
        // Retry button
        let retryBg = SKShapeNode(rectOf: CGSize(width: 180, height: 50), cornerRadius: 25)
        retryBg.fillColor = ClothingColor.green.color
        retryBg.strokeColor = ClothingColor.green.color.darker(by: 0.2)
        retryBg.position = CGPoint(x: 0, y: -80)
        retryBg.name = "retryButton"
        
        let retryLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        retryLabel.fontSize = 20
        retryLabel.fontColor = .white
        retryLabel.text = "🔄 Tekrar Dene"
        retryLabel.verticalAlignmentMode = .center
        retryBg.addChild(retryLabel)
        
        overlay.addChild(retryBg)
        
        // Animate
        overlay.alpha = 0
        overlay.run(SKAction.fadeIn(withDuration: 0.3))
    }
    
    private func clearYarnBalls() {
        clothingItems.forEach { item in
            item.run(SKAction.sequence([
                SKAction.fadeOut(withDuration: 0.2),
                SKAction.removeFromParent()
            ]))
        }
        clothingItems.removeAll()
    }
    
    private func clearPattern() {
        patternDisplay.children.forEach { node in
            node.run(SKAction.sequence([
                SKAction.fadeOut(withDuration: 0.2),
                SKAction.removeFromParent()
            ]))
        }
    }
    
    private func showFloatingScore(_ points: Int, at position: CGPoint, isBonus: Bool = false) {
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.fontSize = isBonus ? 28 : 22
        label.fontColor = isBonus ? ClothingColor.purple.color : ClothingColor.yellow.color
        label.text = "+\(points)"
        label.position = position
        label.zPosition = 100
        addChild(label)
        
        label.run(SKAction.sequence([
            SKAction.group([
                SKAction.moveBy(x: 0, y: 60, duration: 0.8),
                SKAction.fadeOut(withDuration: 0.8)
            ]),
            SKAction.removeFromParent()
        ]))
    }
    
    private func updateComboDisplay() {
        if combo >= 2 {
            comboLabel.text = "🔥 x\(combo)"
            comboLabel.run(SKAction.sequence([
                SKAction.scale(to: 1.3, duration: 0.1),
                SKAction.scale(to: 1.0, duration: 0.1)
            ]))
        } else {
            comboLabel.text = ""
        }
    }
    
    private func updateUI() {
        scoreLabel.text = "Skor: \(score)"
        levelLabel.text = "Seviye: \(level)"
    }
    
    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNodes = nodes(at: location)
        
        // Settings screen handling
        if childNode(withName: "settingsOverlay") != nil {
            for node in touchedNodes {
                if node.name == "closeSettingsButton" || node.parent?.name == "closeSettingsButton" {
                    closeSettingsScreen()
                    return
                }
                if let toggleName = node.name, toggleName.contains("Toggle") {
                    toggleSetting(toggleName)
                    triggerSelectionHaptic()
                    return
                }
            }
            return
        }
        
        // Collection screen handling
        if childNode(withName: "collectionOverlay") != nil {
            if touchedNodes.contains(where: { $0.name == "closeCollectionButton" || $0.parent?.name == "closeCollectionButton" }) {
                closeCollectionScreen()
            }
            return
        }
        
        // Pause menu handling
        if isGamePaused {
            for node in touchedNodes {
                if node.name == "resumeButton" || node.parent?.name == "resumeButton" {
                    resumeGame()
                    return
                }
                if node.name == "pauseMenuButton" || node.parent?.name == "pauseMenuButton" {
                    returnToMainMenu()
                    return
                }
            }
            return
        }
        
        // Menu handling
        if gameState == .menu {
            for node in touchedNodes {
                if node.name == "startButton" || node.parent?.name == "startButton" {
                    triggerImpactHaptic()
                    startGame()
                    return
                }
                if node.name == "settingsButton" || node.parent?.name == "settingsButton" {
                    triggerSelectionHaptic()
                    showSettingsScreen()
                    return
                }
                if node.name == "collectionButton" || node.parent?.name == "collectionButton" {
                    triggerSelectionHaptic()
                    showCollectionScreen()
                    return
                }
            }
            return
        }
        
        // Game over handling
        if gameState == .gameOver {
            if touchedNodes.contains(where: { $0.name == "retryButton" || $0.parent?.name == "retryButton" }) {
                triggerImpactHaptic()
                childNode(withName: "gameOverOverlay")?.removeFromParent()
                startGame()
            }
            return
        }
        
        // Playing state
        if gameState == .playing {
            // Pause button
            if touchedNodes.contains(where: { $0.name == "pauseButton" || $0.parent?.name == "pauseButton" }) {
                triggerSelectionHaptic()
                togglePause()
                return
            }
            
            // Clothing item selection
            for node in touchedNodes {
                if let clothingNode = node as? ClothingItemNode {
                    selectedClothing = clothingNode
                    clothingNode.startDragging()
                    triggerSelectionHaptic()
                    break
                }
                // Also check parent node
                if let parent = node.parent as? ClothingItemNode {
                    selectedClothing = parent
                    parent.startDragging()
                    triggerSelectionHaptic()
                    break
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let clothing = selectedClothing else { return }
        clothing.position = touch.location(in: self)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let clothing = selectedClothing else { return }
        
        clothing.stopDragging()
        
        // Check if dropped on ghost
        if let ghost = currentGhost {
            let ghostFrame = ghost.calculateAccumulatedFrame()
            if ghostFrame.contains(clothing.position) {
                checkClothingMatch(clothing)
            } else {
                clothing.returnToOriginal()
            }
        } else {
            clothing.returnToOriginal()
        }
        
        selectedClothing = nil
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        selectedClothing?.stopDragging()
        selectedClothing?.returnToOriginal()
        selectedClothing = nil
    }
    
    // MARK: - Pause System
    private func togglePause() {
        if isGamePaused {
            resumeGame()
        } else {
            pauseGame()
        }
    }
    
    private func pauseGame() {
        isGamePaused = true
        // Note: we don't set self.isPaused because we want the overlay to keep animating
        // Instead we check isGamePaused in our logic loops.
        
        // Dark overlay
        let overlay = SKShapeNode(rectOf: size)
        overlay.fillColor = UIColor(white: 0, alpha: 0.7)
        overlay.position = CGPoint(x: size.width / 2, y: size.height / 2)
        overlay.zPosition = 300
        overlay.name = "pauseOverlay"
        overlay.alpha = 0
        addChild(overlay)
        overlay.run(SKAction.fadeIn(withDuration: 0.2))
        
        // Pause title
        let pauseLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        pauseLabel.fontSize = 32
        pauseLabel.fontColor = .white
        pauseLabel.text = "⏸️ PAUSED"
        pauseLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.65)
        pauseLabel.zPosition = 301
        pauseLabel.name = "pauseLabel"
        addChild(pauseLabel)
        
        // Resume button
        let resumeButton = SKShapeNode(rectOf: CGSize(width: 180, height: 50), cornerRadius: 25)
        resumeButton.fillColor = ClothingColor.green.color
        resumeButton.strokeColor = ClothingColor.green.color.darker(by: 0.2)
        resumeButton.position = CGPoint(x: size.width / 2, y: size.height * 0.5)
        resumeButton.zPosition = 301
        resumeButton.name = "resumeButton"
        
        let resumeLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        resumeLabel.fontSize = 18
        resumeLabel.fontColor = .white
        resumeLabel.text = "▶️ RESUME"
        resumeLabel.verticalAlignmentMode = .center
        resumeButton.addChild(resumeLabel)
        addChild(resumeButton)
        
        // Main menu button
        let menuButton = SKShapeNode(rectOf: CGSize(width: 180, height: 50), cornerRadius: 25)
        menuButton.fillColor = ClothingColor.red.color
        menuButton.strokeColor = ClothingColor.red.color.darker(by: 0.2)
        menuButton.position = CGPoint(x: size.width / 2, y: size.height * 0.38)
        menuButton.zPosition = 301
        menuButton.name = "pauseMenuButton"
        
        let menuLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        menuLabel.fontSize = 18
        menuLabel.fontColor = .white
        menuLabel.text = "🏠 MAIN MENU"
        menuLabel.verticalAlignmentMode = .center
        menuButton.addChild(menuLabel)
        addChild(menuButton)
        
        pauseOverlay = overlay
    }
    
    private func resumeGame() {
        isGamePaused = false
        
        // Remove pause UI
        childNode(withName: "pauseOverlay")?.run(SKAction.fadeOut(withDuration: 0.2)) {
            self.childNode(withName: "pauseOverlay")?.removeFromParent()
        }
        childNode(withName: "pauseLabel")?.removeFromParent()
        childNode(withName: "resumeButton")?.removeFromParent()
        childNode(withName: "pauseMenuButton")?.removeFromParent()
        
        pauseOverlay = nil
    }
    
    private func returnToMainMenu() {
        // Save stats
        let ghostTypeStr = currentGhost?.ghostType == .rare ? "rare" :
                          currentGhost?.ghostType == .baby ? "baby" :
                          currentGhost?.ghostType == .picky ? "picky" : "standard"
        
        CollectionManager.shared.updateStats(
            score: score,
            ghostsWarmed: ghostsWarmed,
            maxCombo: maxComboThisRound,
            level: level,
            ghostType: ghostTypeStr,
            usedColors: usedColorsThisRound
        )
        
        // Check for new unlocks
        let newUnlocks = CollectionManager.shared.checkUnlocks()
        
        // Clean up game
        resumeGame()
        currentGhost?.removeFromParent()
        currentGhost = nil
        clearYarnBalls()
        clearPattern()
        pauseButton?.removeFromParent()
        timerLabel?.removeFromParent()
        timerBar?.removeFromParent()
        childNode(withName: "timerBarBg")?.removeFromParent()
        
        gameState = .menu
        showMenu()
        
        // Show unlock notifications
        if !newUnlocks.isEmpty {
            showUnlockNotification(newUnlocks.first!)
        }
    }
    
    // MARK: - Settings Screen
    private func showSettingsScreen() {
        // Overlay
        let overlay = SKShapeNode(rectOf: size)
        overlay.fillColor = UIColor(white: 0, alpha: 0.85)
        overlay.position = CGPoint(x: size.width / 2, y: size.height / 2)
        overlay.zPosition = 400
        overlay.name = "settingsOverlay"
        addChild(overlay)
        
        // Title
        let title = SKLabelNode(fontNamed: "AvenirNext-Bold")
        title.fontSize = 28
        title.fontColor = .white
        title.text = "⚙️ SETTINGS"
        title.position = CGPoint(x: size.width / 2, y: size.height * 0.8)
        title.zPosition = 401
        title.name = "settingsTitle"
        addChild(title)
        
        let settings = CollectionManager.shared.settings
        var yPos = size.height * 0.65
        
        // Music toggle
        createSettingToggle(
            name: "musicToggle",
            label: "🎵 Music",
            isOn: settings.musicEnabled,
            yPosition: yPos
        )
        yPos -= 70
        
        // Sound effects toggle
        createSettingToggle(
            name: "sfxToggle",
            label: "🔊 Sound FX",
            isOn: settings.soundEffectsEnabled,
            yPosition: yPos
        )
        yPos -= 70
        
        // Haptic toggle
        createSettingToggle(
            name: "hapticToggle",
            label: "📳 Haptics",
            isOn: settings.hapticEnabled,
            yPosition: yPos
        )
        
        // Close button
        let closeButton = SKShapeNode(rectOf: CGSize(width: 150, height: 45), cornerRadius: 22)
        closeButton.fillColor = ClothingColor.blue.color
        closeButton.strokeColor = ClothingColor.blue.color.darker(by: 0.2)
        closeButton.position = CGPoint(x: size.width / 2, y: size.height * 0.2)
        closeButton.zPosition = 401
        closeButton.name = "closeSettingsButton"
        
        let closeLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        closeLabel.fontSize = 16
        closeLabel.fontColor = .white
        closeLabel.text = "✓ CLOSE"
        closeLabel.verticalAlignmentMode = .center
        closeButton.addChild(closeLabel)
        addChild(closeButton)
    }
    
    private func createSettingToggle(name: String, label: String, isOn: Bool, yPosition: CGFloat) {
        // Label
        let labelNode = SKLabelNode(fontNamed: "AvenirNext-Medium")
        labelNode.fontSize = 18
        labelNode.fontColor = .white
        labelNode.text = label
        labelNode.horizontalAlignmentMode = .left
        labelNode.position = CGPoint(x: 50, y: yPosition)
        labelNode.zPosition = 401
        labelNode.name = "\(name)Label"
        addChild(labelNode)
        
        // Toggle
        let toggle = SKShapeNode(rectOf: CGSize(width: 60, height: 30), cornerRadius: 15)
        toggle.fillColor = isOn ? ClothingColor.green.color : UIColor(white: 0.4, alpha: 1.0)
        toggle.strokeColor = .white
        toggle.lineWidth = 2
        toggle.position = CGPoint(x: size.width - 60, y: yPosition)
        toggle.zPosition = 401
        toggle.name = name
        
        let knob = SKShapeNode(circleOfRadius: 12)
        knob.fillColor = .white
        knob.position = CGPoint(x: isOn ? 15 : -15, y: 0)
        knob.name = "\(name)Knob"
        toggle.addChild(knob)
        
        addChild(toggle)
    }
    
    private func toggleSetting(_ name: String) {
        var settings = CollectionManager.shared.settings
        
        switch name {
        case "musicToggle":
            settings.musicEnabled.toggle()
            updateToggleVisual(name: name, isOn: settings.musicEnabled)
            
            // Update music player
            if settings.musicEnabled {
                backgroundMusicPlayer?.volume = settings.musicVolume
                if backgroundMusicPlayer?.isPlaying == false {
                    backgroundMusicPlayer?.play()
                }
            } else {
                backgroundMusicPlayer?.volume = 0
                backgroundMusicPlayer?.pause()
            }
            
        case "sfxToggle":
            settings.soundEffectsEnabled.toggle()
            updateToggleVisual(name: name, isOn: settings.soundEffectsEnabled)
            
            // Update wind ambience
            if settings.soundEffectsEnabled {
                windSoundPlayer?.volume = 0.3
                if windSoundPlayer?.isPlaying == false {
                    windSoundPlayer?.play()
                }
            } else {
                windSoundPlayer?.volume = 0
                windSoundPlayer?.pause()
            }
            
        case "hapticToggle":
            settings.hapticEnabled.toggle()
            updateToggleVisual(name: name, isOn: settings.hapticEnabled)
            if settings.hapticEnabled {
                impactGenerator.impactOccurred()
            }
            
        default:
            break
        }
        
        CollectionManager.shared.updateSettings(settings)
    }
    
    private func updateToggleVisual(name: String, isOn: Bool) {
        guard let toggle = childNode(withName: name) as? SKShapeNode,
              let knob = toggle.childNode(withName: "\(name)Knob") as? SKShapeNode else { return }
        
        toggle.fillColor = isOn ? ClothingColor.green.color : UIColor(white: 0.4, alpha: 1.0)
        knob.run(SKAction.moveTo(x: isOn ? 15 : -15, duration: 0.2))
    }
    
    private func closeSettingsScreen() {
        childNode(withName: "settingsOverlay")?.removeFromParent()
        childNode(withName: "settingsTitle")?.removeFromParent()
        childNode(withName: "musicToggle")?.removeFromParent()
        childNode(withName: "musicToggleLabel")?.removeFromParent()
        childNode(withName: "sfxToggle")?.removeFromParent()
        childNode(withName: "sfxToggleLabel")?.removeFromParent()
        childNode(withName: "hapticToggle")?.removeFromParent()
        childNode(withName: "hapticToggleLabel")?.removeFromParent()
        childNode(withName: "closeSettingsButton")?.removeFromParent()
    }
    
    // MARK: - Collection Screen
    private func showCollectionScreen() {
        // Overlay
        let overlay = SKShapeNode(rectOf: size)
        overlay.fillColor = UIColor(white: 0, alpha: 0.9)
        overlay.position = CGPoint(x: size.width / 2, y: size.height / 2)
        overlay.zPosition = 400
        overlay.name = "collectionOverlay"
        addChild(overlay)
        
        // Title
        let title = SKLabelNode(fontNamed: "AvenirNext-Bold")
        title.fontSize = 28
        title.fontColor = .white
        let progress = CollectionManager.shared.collectionProgress
        title.text = "👕 COLLECTION (\(progress.unlocked)/\(progress.total))"
        title.position = CGPoint(x: size.width / 2, y: size.height * 0.88)
        title.zPosition = 401
        title.name = "collectionTitle"
        addChild(title)
        
        // Outfit grid
        let columns = 2
        let itemWidth: CGFloat = 140
        let itemHeight: CGFloat = 100
        let startX = (size.width - CGFloat(columns) * itemWidth) / 2 + itemWidth / 2
        var xPos = startX
        var yPos = size.height * 0.75
        
        for (index, outfit) in OutfitType.allCases.enumerated() {
            let isUnlocked = CollectionManager.shared.isOutfitUnlocked(outfit)
            
            let card = SKShapeNode(rectOf: CGSize(width: itemWidth - 10, height: itemHeight - 10), cornerRadius: 10)
            card.fillColor = isUnlocked ? ClothingColor.purple.color.withAlphaComponent(0.3) : UIColor(white: 0.2, alpha: 0.8)
            card.strokeColor = isUnlocked ? ClothingColor.purple.color : UIColor(white: 0.4, alpha: 1.0)
            card.lineWidth = 2
            card.position = CGPoint(x: xPos, y: yPos)
            card.zPosition = 401
            addChild(card)
            
            // Emoji or lock
            let icon = SKLabelNode(text: isUnlocked ? outfit.emoji : "🔒")
            icon.fontSize = 30
            icon.position = CGPoint(x: 0, y: 10)
            icon.zPosition = 402
            card.addChild(icon)
            
            // Name
            let nameLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
            nameLabel.fontSize = 11
            nameLabel.fontColor = isUnlocked ? .white : UIColor(white: 0.6, alpha: 1.0)
            nameLabel.text = outfit.displayName
            nameLabel.position = CGPoint(x: 0, y: -25)
            nameLabel.zPosition = 402
            card.addChild(nameLabel)
            
            // Update position
            if (index + 1) % columns == 0 {
                xPos = startX
                yPos -= itemHeight
            } else {
                xPos += itemWidth
            }
        }
        
        // Close button
        let closeButton = SKShapeNode(rectOf: CGSize(width: 150, height: 45), cornerRadius: 22)
        closeButton.fillColor = ClothingColor.blue.color
        closeButton.strokeColor = ClothingColor.blue.color.darker(by: 0.2)
        closeButton.position = CGPoint(x: size.width / 2, y: size.height * 0.08)
        closeButton.zPosition = 401
        closeButton.name = "closeCollectionButton"
        
        let closeLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        closeLabel.fontSize = 16
        closeLabel.fontColor = .white
        closeLabel.text = "✓ KAPAT"
        closeLabel.verticalAlignmentMode = .center
        closeButton.addChild(closeLabel)
        addChild(closeButton)
    }
    
    private func closeCollectionScreen() {
        enumerateChildNodes(withName: "//*") { node, _ in
            if node.zPosition >= 400 {
                node.removeFromParent()
            }
        }
    }
    
    // MARK: - Unlock Notification
    private func showUnlockNotification(_ outfit: OutfitType) {
        let banner = SKShapeNode(rectOf: CGSize(width: 280, height: 80), cornerRadius: 15)
        banner.fillColor = ClothingColor.yellow.color
        banner.strokeColor = .white
        banner.lineWidth = 2
        banner.position = CGPoint(x: size.width / 2, y: size.height + 50)
        banner.zPosition = 500
        addChild(banner)
        
        let text = SKLabelNode(fontNamed: "AvenirNext-Bold")
        text.fontSize = 14
        text.fontColor = .black
        text.text = "🎉 NEW ITEM UNLOCKED!"
        text.position = CGPoint(x: 0, y: 15)
        banner.addChild(text)
        
        let outfitText = SKLabelNode(fontNamed: "AvenirNext-Medium")
        outfitText.fontSize = 18
        outfitText.fontColor = .black
        outfitText.text = "\(outfit.emoji) \(outfit.displayName)"
        outfitText.position = CGPoint(x: 0, y: -15)
        banner.addChild(outfitText)
        
        // Animate
        let slideDown = SKAction.moveTo(y: size.height - 60, duration: 0.4)
        slideDown.timingMode = .easeOut
        let wait = SKAction.wait(forDuration: 3.0)
        let slideUp = SKAction.moveTo(y: size.height + 50, duration: 0.3)
        slideUp.timingMode = .easeIn
        
        banner.run(SKAction.sequence([slideDown, wait, slideUp, SKAction.removeFromParent()]))
    }
    
    // MARK: - Difficulty Updates
    private func updateDifficultyForLevel() {
        // Increase speed every 2 levels
        speedMultiplier = 1.0 + CGFloat(level - 1) * 0.1
        
        // Reduce time as level increases (minimum 8 seconds)
        maxTime = max(8.0, 40.0 - Double(level - 1) * 0.5)
        
        // Enable fake yarns at level 3
        hasFakeYarns = level >= 3
        fakeYarnCount = level >= 5 ? 2 : (level >= 3 ? 1 : 0)
        
        // Enable locked yarns at level 5
        hasLockedYarns = level >= 5
        
        // Enable timed yarns at level 7
        hasTimedYarns = level >= 7
    }
    
    // MARK: - Haptic Feedback
    private func triggerHaptic(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        guard CollectionManager.shared.settings.hapticEnabled else { return }
        notificationGenerator.notificationOccurred(type)
    }
    
    private func triggerImpactHaptic() {
        guard CollectionManager.shared.settings.hapticEnabled else { return }
        impactGenerator.impactOccurred()
    }
    
    private func triggerSelectionHaptic() {
        guard CollectionManager.shared.settings.hapticEnabled else { return }
        selectionGenerator.selectionChanged()
    }
}

// MARK: - Color Extensions
extension UIColor {
    func darker(by percentage: CGFloat) -> UIColor {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return UIColor(hue: h, saturation: s, brightness: max(b - percentage, 0), alpha: a)
    }
    
    func lighter(by percentage: CGFloat) -> UIColor {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return UIColor(hue: h, saturation: max(s - percentage, 0), brightness: min(b + percentage, 1), alpha: a)
    }
}

// MARK: - SKNode Extensions
extension SKNode {
    func playSFX(_ fileName: String) {
        guard CollectionManager.shared.settings.soundEffectsEnabled else { return }
        
        let nameOnly = (fileName as NSString).deletingPathExtension
        let ext = (fileName as NSString).pathExtension
        
        if Bundle.main.url(forResource: nameOnly, withExtension: ext) != nil {
            run(SKAction.playSoundFileNamed(fileName, waitForCompletion: false))
        }
    }
}
