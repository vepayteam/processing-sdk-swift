//
//  LoadingScreen.swift
//  MoneyTransfer
//
//  Created by Bohdan Hrozian on 17.01.2024.
//

import UIKit

public final class LoadingScreen: UIView {

    // MARK: - Big Objects

    private let glass = GlassmorphismView(density: .zero, cornerRadius: .zero, distance: .zero, animated: false)

    private let gradient = CAGradientLayer()
    private let gradientMask = CAShapeLayer()

    // MARK: - Animation Propertys

    /// 0 - 1
    private var targetSize: CGFloat = 48

    // MARK: - Init

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public init() {
        super.init(frame: .zero)
        setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        glass.frame = bounds
        let gradientSize = targetSize
        gradient.frame = CGRect(x: bounds.width / 2 - targetSize / 2,
                                y: bounds.height / 2 - targetSize / 2,
                                width: gradientSize, height: gradientSize)
        gradientMask.frame = gradient.bounds
        setGradientMask()
    }

}


// MARK: - Start / Stop Animation

extension LoadingScreen {
    
    public func startAnimating() {
        glass.makeGlassmorphismEffect()
    }

    public func stopAnimationg(removeOnCompletion: Bool = true) {
        glass.makeGlassmorphismEffect(density: .zero, cornerRadius: .zero, distance: .zero)
        if removeOnCompletion {
            DispatchQueue.main.asyncAfter(deadline: .now() + glass.animationDuration) { [weak self] in
                self?.removeFromSuperview()
            }
        }
    }
    
}


// MARK: - Configuration & Setup

extension LoadingScreen {

    public func setCircle(size: CGFloat) {
        targetSize = size
        setGradientMask()
    }

    private func setup() {
        // Glass
        addSubview(glass)
        glass.layer.zPosition = 5

        // Gradient
        layer.addSublayer(gradient)
        gradient.zPosition = 6
        gradient.setAffineTransform(.init(rotationAngle: .pi / -2))
        let limequat = UIColor.limequat
        gradient.colors = [limequat.cgColor, limequat.withAlphaComponent(0.64).cgColor, limequat.withAlphaComponent(0.12).cgColor]


        // Gradient Mask
        gradient.mask = gradientMask
        gradientMask.fillColor = nil
        gradientMask.strokeColor = UIColor.white.cgColor
        gradientMask.lineWidth = 8
        gradientMask.lineCap = .round

        setupProgressAnimation()
    }

}


// MARK: - Progress Animation

private extension LoadingScreen {
    
    private func setupProgressAnimation() {

        let beginTime: CFTimeInterval = 0.5
        let durationStart: CFTimeInterval = 1.2
        let durationStop: CFTimeInterval = 0.7

        let durationGroup: CFTimeInterval = durationStart + beginTime

        func maskPath(property: String) -> String {
            "\(property)"
        }

        let start: [Float] = [0.13, 0.21, 0.34, 0.55]
        let end = start.map { $0 * 1.618033 }
        func function(timings: [Float]) -> CAMediaTimingFunction {
            .init(controlPoints: timings[0], timings[1], timings[2], timings[3])
        }
//        0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377
        // 1.618033
        // Mask Stroke Start
        let maskAnimationStart = CABasicAnimation(keyPath: maskPath(property: "strokeStart"))
        maskAnimationStart.duration = durationStart
//        maskAnimationStart.timingFunction = CAMediaTimingFunction(controlPoints: 0.98700013, 0.63103287, 0.33978693, 0.74429518)
        maskAnimationStart.timingFunction = function(timings: end)
        maskAnimationStart.fromValue = 0
        maskAnimationStart.toValue = 1
        maskAnimationStart.beginTime = beginTime

        // 1.618
        // Mask Stroke Stop
        let maskAnimationStop = CABasicAnimation(keyPath: maskPath(property: "strokeEnd"))
        maskAnimationStop.duration = durationStop
//        maskAnimationStop.timingFunction = CAMediaTimingFunction(controlPoints: 0.61, 0.39, 0.21, 0.46)
        maskAnimationStop.timingFunction = function(timings: start)
        maskAnimationStop.fromValue = 0
        maskAnimationStop.toValue = 1

        // Mask Rotation
        let maskAnimationRotation = CABasicAnimation(keyPath: maskPath(property: "transform.rotation"))
        maskAnimationRotation.byValue = 2 * Float.pi
        maskAnimationRotation.timingFunction = CAMediaTimingFunction(name: .linear)

        // Mask Group
        let maskAnimation = CAAnimationGroup()
        maskAnimation.animations = [maskAnimationRotation, maskAnimationStart, maskAnimationStop]
        maskAnimation.duration = durationGroup
        maskAnimation.repeatCount = .infinity
        maskAnimation.isRemovedOnCompletion = false
        maskAnimation.fillMode = .forwards

        // Gradient Rotation
//        let animationRotation = CABasicAnimation(keyPath: "transform.rotation")
//        animationRotation.byValue = -2 * Float.pi
//        animationRotation.duration = durationGroup * 1.618
//        animationRotation.repeatCount = .infinity
//        animationRotation.isRemovedOnCompletion = false
//        animationRotation.fillMode = .forwards
//        animationRotation.timingFunction = CAMediaTimingFunction(name: .linear)

        gradientMask.add(maskAnimation, forKey: "maskAnimation")
    }

    private func setGradientMask() {
        gradientMask.path = UIBezierPath(arcCenter: .init(x: gradient.bounds.midX, y: gradient.bounds.midX), radius: targetSize / 2 - 4, startAngle: -.pi, endAngle: .pi, clockwise: true).cgPath
    }
    
}
