import UIKit

class CustomIndicatorView: UIView {
    
    private let shapeLayer = CAShapeLayer()
    
    // Initialize with customizable size and color (default: blue)
    init(frame: CGRect, color: UIColor = .blue, width: CGFloat = 4.0) {
        super.init(frame: frame)
        setupLayer(color: color, lineWidth: width)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayer(color: .blue) // Default to blue if no color is provided
    }
    
    public func setupLayer(color: UIColor, lineWidth: CGFloat = 4.0) {
        // Set the stroke color to the provided color and fill color to transparent
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.lineWidth = lineWidth // Adjust thickness if needed
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineCap = .round
        
        // Create a circular path that stays in place
        let radius: CGFloat = min(frame.width, frame.height) / 2 - shapeLayer.lineWidth / 2
        let circularPath = UIBezierPath(arcCenter: CGPoint(x: frame.width / 2, y: frame.height / 2),
                                        radius: radius,
                                        startAngle: -(.pi / 2),  // Start at top
                                        endAngle: 1.5 * .pi,  // Full circle
                                        clockwise: true)
        
        shapeLayer.path = circularPath.cgPath
        layer.addSublayer(shapeLayer)
        
        startAnimating()
    }
    
    func startAnimating() {
        // Create the strokeEnd animation
        let strokeEndAnimation = CABasicAnimation(keyPath: "strokeEnd")
        strokeEndAnimation.fromValue = 0
        strokeEndAnimation.toValue = 1
        strokeEndAnimation.duration = 0.6 // Faster animation
        strokeEndAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        // Create the strokeStart animation
        let strokeStartAnimation = CABasicAnimation(keyPath: "strokeStart")
        strokeStartAnimation.fromValue = 0
        strokeStartAnimation.toValue = 1
        strokeStartAnimation.duration = 0.6 // Faster animation
        strokeStartAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        strokeStartAnimation.beginTime = 0.3 // Halfway through the strokeEnd

        // Combine both animations into an animation group
        let groupAnimation = CAAnimationGroup()
        groupAnimation.animations = [strokeEndAnimation, strokeStartAnimation]
        groupAnimation.duration = 0.9 // Total duration
        groupAnimation.repeatCount = .infinity

        // Apply the animation group to the shape layer
        shapeLayer.add(groupAnimation, forKey: "circleStrokeSpin")
        isHidden = false
    }
    
    func stopAnimating() {
        shapeLayer.removeAllAnimations()
        isHidden = true
    }
}
