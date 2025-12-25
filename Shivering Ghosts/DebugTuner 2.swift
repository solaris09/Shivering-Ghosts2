import SpriteKit

// Simple slider used by DebugTuner
private class SliderNode: SKNode {
    let nameLabel: SKLabelNode
    let valueLabel: SKLabelNode
    private let track: SKShapeNode
    private let thumb: SKShapeNode
    private let minValue: CGFloat
    private let maxValue: CGFloat
    private(set) var value: CGFloat
    var onChange: ((CGFloat)->Void)?
    private var isDragging = false

    init(width: CGFloat = 260, name: String, min: CGFloat, max: CGFloat, initial: CGFloat) {
        self.nameLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
        self.valueLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
        self.minValue = min
        self.maxValue = max
        self.value = initial

        // track
        let rect = CGRect(x: -width/2, y: -6, width: width, height: 12)
        track = SKShapeNode(rect: rect, cornerRadius: 6)
        track.fillColor = UIColor(white: 1.0, alpha: 0.08)
        track.strokeColor = UIColor(white: 1.0, alpha: 0.15)

        // thumb
        thumb = SKShapeNode(circleOfRadius: 10)
        thumb.fillColor = UIColor.white
        thumb.strokeColor = UIColor(white: 0.0, alpha: 0.2)
        thumb.glowWidth = 1

        super.init()
        isUserInteractionEnabled = true

        nameLabel.text = name
        nameLabel.fontSize = 14
        nameLabel.fontColor = .white
        nameLabel.horizontalAlignmentMode = .left
        nameLabel.verticalAlignmentMode = .center
        nameLabel.position = CGPoint(x: -width/2, y: 20)
        addChild(nameLabel)

        valueLabel.text = String(format: "%.2f", value)
        valueLabel.fontSize = 12
        valueLabel.fontColor = .white
        valueLabel.horizontalAlignmentMode = .right
        valueLabel.verticalAlignmentMode = .center
        valueLabel.position = CGPoint(x: width/2, y: 20)
        addChild(valueLabel)

        addChild(track)
        addChild(thumb)

        updateThumbPosition(width: width)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }

    private func updateThumbPosition(width: CGFloat) {
        let t = (value - minValue) / (maxValue - minValue)
        let x = (-width/2) + (t * width)
        thumb.position = CGPoint(x: x, y: 0)
        valueLabel.text = String(format: "%.2f", value)
    }

    private func setValueFrom(x: CGFloat, width: CGFloat) {
        let clamped = max(-width/2, min(width/2, x))
        let t = (clamped + width/2) / width
        value = minValue + t * (maxValue - minValue)
        onChange?(value)
        updateThumbPosition(width: width)
    }

    // Public setter to programmatically change value
    func setValue(_ newValue: CGFloat) {
        value = max(minValue, min(maxValue, newValue))
        updateThumbPosition(width: track.frame.width)
    }

    // Touch handling for thumb dragging
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let t = touches.first else { return }
        let p = t.location(in: self)
        if thumb.contains(p) { isDragging = true }
        else { isDragging = true; setValueFrom(x: p.x, width: track.frame.width) }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let t = touches.first, isDragging else { return }
        let p = t.location(in: self)
        setValueFrom(x: p.x, width: track.frame.width)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isDragging = false
    }
}

// Public tuner used by GameScene
class DebugTuner: SKNode {
    private let ghostKey: String
    private var sliders: [String: SliderNode] = [:]
    var onChange: ((String, CGFloat)->Void)?

    init(ghostTypeKey: String, initial: [String:CGFloat]) {
        self.ghostKey = ghostTypeKey
        super.init()
        isUserInteractionEnabled = true

        // background
        let bg = SKShapeNode(rectOf: CGSize(width: 320, height: 320), cornerRadius: 14)
        bg.fillColor = UIColor(white: 0.1, alpha: 0.9)
        bg.strokeColor = UIColor(white: 1.0, alpha: 0.06)
        bg.zPosition = 1000
        addChild(bg)

        // Title
        let title = SKLabelNode(fontNamed: "AvenirNext-DemiBold")

        title.text = "Debug Tuner"
        title.fontSize = 16
        title.fontColor = .white
        title.position = CGPoint(x: 0, y: 130)
        addChild(title)

        // Define sliders with ranges
        let definitions: [(String, CGFloat, CGFloat)] = [
            ("hatWidthFactor", 0.3, 1.2),
            ("hatYFactor", -0.4, 0.6),
            ("scarfWidthFactor", 0.3, 1.2),
            ("scarfYFactor", -0.4, 0.6),
            ("sweaterWidthFactor", 0.3, 1.2),
            ("sweaterYFactor", -0.6, 0.1)
        ]

        var y: CGFloat = 70
        for (name, min, max) in definitions {
            let initialVal = initial[name] ?? ((min+max)/2)
            let slider = SliderNode(width: 260, name: name, min: min, max: max, initial: initialVal)
            slider.position = CGPoint(x: 0, y: y)
            slider.onChange = { [weak self] newVal in
                self?.saveValue(name: name, value: newVal)
                self?.onChange?(name, newVal)
            }
            addChild(slider)
            sliders[name] = slider
            y -= 42
        }

        // Close hint
        let hint = SKLabelNode(fontNamed: "AvenirNext-Regular")
        hint.text = "Tap DBG to close"
        hint.fontSize = 12
        hint.fontColor = UIColor(white: 0.8, alpha: 1.0)
        hint.position = CGPoint(x: 0, y: -140)
        addChild(hint)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }

    func updateValues(_ values: [String:CGFloat]) {
        for (k, v) in values {
            sliders[k]?.setValue(v)
        }
    }



    private func saveValue(name: String, value: CGFloat) {
        // store under global key per ghost type
        UserDefaults.standard.set(Double(value), forKey: "tuner.\(ghostKey).\(name)")
    }
}
