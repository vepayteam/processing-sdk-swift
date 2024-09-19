//
//  VepayCardNumberField.swift
//  VepaySDK
//
//  Created by Bohdan Hrozian on 15.09.2024.
//


import UIKit

public final class VepayCardNumberField: UIView {


    // MARK: - Public Propertys

    /// Use card or cardMasked to set value. Don't set directly to field.text
    public let field: UITextField = UITextField()
    private let underline = CAGradientLayer()

    public var delegate: VepayCardNumberFieldDelegate?

    public func removeUnderline() {
        underline.removeFromSuperlayer()
    }

    public weak var nextField: UIView? {
        didSet {
            field.returnKeyType = nextField == nil ? .done : .next
        }
    }

    /// Must contain 16 or more X
    public var cardMask: String = "XXXX XXXX XXXX XXXX XXXX" {
        didSet {
            formatField(textField: field)
        }
    }


    // MARK: - Validation Propertys

    public private(set) var cardReady: Bool = false {
        didSet {
            if oldValue != cardReady {
                delegate?.cardReadinessChanged(field: self, isReady: cardReady)
            }
        }
    }

    public private(set) var progress: CGFloat = .zero {
        didSet {
            delegate?.cardProgressChanged(field: self, progress: progress)
        }
    }

    public var identifier = VepayCreditCardIdentifier()

    public var paymentService: VepayPaymentService? {
        didSet {
            if oldValue != paymentService {
                delegate?.cardIdentificationChanged(field: self, service: paymentService)
            }
        }
    }


    // MARK: - Life Cycle

    convenience init() {
        self.init(frame: .zero)
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        underline.frame = .init(x: .zero, y: field.frame.maxY + 11, width: bounds.width, height: 1)
    }

}


// MARK: - Get & Set

extension VepayCardNumberField {
    
    /// Unmasked, Only numbers
    public var card: String {
        get {
            cardMasked.numbersOnly()
        }
        set {
            field.text = newValue
            formatField(textField: field)
        }
    }

    /// Returns masked cardNumber (same as cardMask)
    /// You can change masking using cardNumberMask.
    /// For unmasked use card
    public var cardMasked: String {
        get {
            field.text ?? ""
        }
        set {
            field.text = newValue
            formatField(textField: field)
        }
    }

}


// MARK: - Text Field Delegate

extension VepayCardNumberField: UITextFieldDelegate {

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        nextField?.becomeFirstResponder()
        return true
    }

}



// MARK: - Text Field Formatation

extension VepayCardNumberField {

    @objc private func formatField(textField: UITextField) {
        guard let inputText = textField.text else { return }

        var targetCursorPosition = 0
        if let startPosition = textField.selectedTextRange?.start {
            targetCursorPosition = textField.offset(from: textField.beginningOfDocument, to: startPosition)
        }

        let numbers = inputText.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        targetCursorPosition -= inputText.count - numbers.count

        var result = ""
        var index = numbers.startIndex

        // iterate over the mask characters until the iterator of numbers ends
        for ch in cardMask where index < numbers.endIndex {
            if ch == "X" {
                // mask requires a number in this place, so take the next one
                result.append(numbers[index])

                // move numbers iterator to the next index
                index = numbers.index(after: index)

            } else {
                result.append(ch)
                targetCursorPosition += 1
            }
        }

        textField.text = result
        if inputText != result {
            delegate?.cardChanged(field: self, number: result)
        }

        DispatchQueue.main.async {
            if let targetPosition = textField.position(from: textField.beginningOfDocument, offset: targetCursorPosition) {
                textField.selectedTextRange = textField.textRange(from: targetPosition, to: targetPosition)
            }
        }

        validateCard()

        let progress = min(CGFloat(numbers.count) / CGFloat(paymentService?.validNumberLength.lowerBound ?? 13), 1)
        self.progress = cardReady ? progress : progress - 0.1
    }

}

// MARK: - Card Validation

private extension VepayCardNumberField {
    
    private func validateCard() {
        if card.count > 5 {
            let (service, ready) = identifier.identifyAndValidate(card: cardMasked)
            paymentService = service
            cardReady = ready
        } else {
            paymentService = nil
            cardReady = false
        }
    }

}


// MARK: - Setup

extension VepayCardNumberField {
    
    private func setup() {
        field.placeholder = "Введите номер карты"
        field.font = .subHeading
        field.delegate = self
        field.keyboardType = .numberPad
        field.textContentType = .creditCardNumber

        field.addTarget(self, action: #selector(formatField), for: .editingChanged)

        addSubview(field)
        field.translatesAutoresizingMaskIntoConstraints = false
        field.topAnchor.constraint(equalTo: topAnchor).isActive = true
        field.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        field.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        field.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12).isActive = true

        underline.startPoint = .init(x: .zero, y: 0.5)
        underline.endPoint = .init(x: 1, y: 0.5)
        underline.colors = [UIColor.coal.cgColor, UIColor.coal.withAlphaComponent(.zero).cgColor]
        underline.locations = [0, 1]
        layer.addSublayer(underline)
    }

}


// MARK: - VepayCardNumberTextFieldDelegate

public protocol VepayCardNumberFieldDelegate {

    /// - Parameter number: Masked
    func cardChanged(field: VepayCardNumberField, number: String)

    func cardIdentificationChanged(field: VepayCardNumberField, service: VepayPaymentService?)

    func cardReadinessChanged(field: VepayCardNumberField, isReady: Bool)
    func cardProgressChanged(field: VepayCardNumberField, progress: CGFloat)

}

@available(iOS 17, *)
#Preview {
    VepayCardNumberField()
}
