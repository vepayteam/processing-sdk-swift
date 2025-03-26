//
//  VepayCommonTextField.swift
//  MoneyTransfer
//
//  Created by Bohdan Hrozian on 3/17/25.
//

import UIKit

open class VepayCommonTextField: UIView {

 
    // MARK: - TextField

    public let textField: VepayFormattableTextField

    open weak var defaultDelegate: CommonTextFieldDelegate!

    open var returnKeyType: UIReturnKeyType = .next {
        didSet {
            textField.returnKeyType = returnKeyType
        }
    }


    // MARK: - Init

    public convenience init() {
        self.init(frame: .zero)
    }

    public override init(frame: CGRect) {
        textField = .init(frame: .zero)
        super.init(frame: frame)
        setup()
    }

    public required init?(coder: NSCoder) {
        textField = .init(frame: .zero)
        super.init(coder: coder)
        setup()
    }

    open func additionalSetup() { }

    open var text: String {
        get {
            textField.text ?? textField.attributedText?.string ?? ""
        }
        set {
            textField.text = textField.formatter?.formatAndValidate(text: newValue) ?? newValue
        }
    }

    open var placeholder: String? {
        get {
            return textField.attributedPlaceholder?.string ?? textField.placeholder
        } set(text) {
            if let text = text {
                textField.attributedPlaceholder = .init(string: text, attributes: [
                    .font: (textField.font ?? .bodyLarge)!,
                    .foregroundColor: tintColor.withAlphaComponent(0.48)
                ])
            } else {
                textField.placeholder = nil
            }
        }
    }


    // MARK: - Tint Color

    @IBInspectable
    open var isLight: Bool = true {
        didSet {
            self.updateTint()
        }
    }

    open var ready: Bool {
        get {
            textField.fieldReady
        }
        set {
            if ready != newValue {
                textField.fieldReady = newValue
                defaultDelegate?.textFieldReadyChanged(self, ready: newValue)
            }
        }
    }

    open func updateTint() {
        tintColor = showError ? isLight ? .cherry : .strawberry : isLight ? .ice : .coal
    }
    
    open override func tintColorDidChange() {
        textField.textColor = tintColor
        if placeholder != nil {
            placeholder = placeholder
        }
//        updateRightButton()
        updateGradientLineColor()
    }


    // MARK: - Error

    open var showError: Bool = false {
        didSet {
            if showError != oldValue {
                updateTint()
                
                (showError ? textField.addTarget : textField.removeTarget)(self, #selector(removeShowError), .allEditingEvents)
            }
        }
    }

    @objc private func removeShowError() {
        showError = false
    }

    open func showErrorIfNotReady() {
        if !ready {
            showError = true
        }
    }


    // MARK: - Right Button

//    private(set) weak var rightButton: UIButton!
//    open var rightButtonImage: UIImage? {
//        get {
//            rightButton?.imageView?.image
//        }
//        set {
//            let button = rightButton
//            guard newValue != nil else {
//                rightButton?.removeFromSuperview()
//                textField.removeTarget(self, action: #selector(updateRightButton), for: .allEditingEvents)
//                button?.removeTarget(self, action: #selector(didTapRightButton), for: .touchUpInside)
//                return
//            }
//
//            if button == nil {
//                let button = UIButton(type: .custom)
//                addSubview(button, leading: textField.trailingAnchor, top: nil, trailing: trailingAnchor, trailingConstant: -16, bottom: nil)
//                button.widthAnchor.constraint(equalToConstant: 24).isActive = true
//                button.heightAnchor.constraint(equalTo: button.widthAnchor).isActive = true
//
//                button.setImage(newValue, for: .normal)
//                button.playSoftImpactOnTouchUpInside = true
//                button.addTarget(self, action: #selector(didTapRightButton), for: .touchUpInside)
//
//                rightButton = button
//                textField.addTarget(self, action: #selector(updateRightButton), for: .allEditingEvents)
//                updateRightButton()
//            } else {
//                button?.setImage(newValue, for: .normal)
//            }
//        }
//    }

//    @objc open func updateRightButton() {
//        UIView.animateSimple { [weak self] in
//            if let self = self {
//                self.rightButton?.tintColor = self.tintColor.withAlphaComponent(self.textField.isFirstResponder ? 1 : 0.48)
//            }
//        }
//    }
//
//    @objc open func didTapRightButton(_ button: UIButton) {
//        textField.becomeFirstResponder()
//    }

    
    // MARK: - Gradient

    open var withGradient: Bool = true {
        didSet {
            gradient.isHidden = !withGradient
        }
    }
    /// Min height = 44
    open var setMinHeight: Bool = true {
        didSet {
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
    }
    public let gradient = CAGradientLayer()

    open func updateGradientLineColor() {
        guard withGradient else { return }
        let toColors = [tintColor.cgColor, tintColor.cgColor]

        let colorsAnimation = CABasicAnimation(keyPath: "colors")
        colorsAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        colorsAnimation.fromValue = gradient.colors
        colorsAnimation.toValue = toColors
        colorsAnimation.duration = 0.1618

        gradient.colors = toColors
        gradient.add(colorsAnimation, forKey: "colors")

        let mustBeX: CGFloat = 1
        if gradient.endPoint.x != mustBeX {
            let animation = CABasicAnimation(keyPath: "endPoint")
            animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
            animation.fromValue = gradient.endPoint
            animation.toValue = CGPoint(x: mustBeX, y: gradient.endPoint.y)
            animation.duration = 0.1618

            gradient.endPoint.x = mustBeX
            gradient.add(animation, forKey: "endPoint")
        }
    }

    open override var canBecomeFocused: Bool {
        defaultDelegate?.textFieldShouldBeginEditing(self) ?? true
    }

}


// MARK: - Setup

private extension VepayCommonTextField {

    private func setup() {
        setViews()
        additionalSetup()

        updateTint()
    }

    private func setViews() {
        textField.defaultDelegate = self

        textField.returnKeyType = returnKeyType
        backgroundColor = .clear

        // TextField
        textField.textColor = tintColor
        textField.font = .bodyLarge
        if placeholder != nil {
            placeholder = placeholder
        }
        
        addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.topAnchor.constraint(equalTo: topAnchor).isActive = true
        textField.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        textField.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        textField.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        textField.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

        // Gradient
        layer.addSublayer(gradient)
        gradient.startPoint = CGPoint(x: 0.25, y: 0.5)
        gradient.endPoint = CGPoint(x: 0.75, y: 0.5)
        gradient.frame = CGRect(x: 0, y: bounds.height - 1, width: bounds.width, height: 0.34)
    }

}
