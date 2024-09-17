//
//  VepayCVVField.swift
//  VepaySDK
//
//  Created by Bohdan Hrozian on 17.09.2024.
//

import UIKit

public final class VepayCVVField: UIView {
 
    // MARK: - Public Propertys

    public let field: UITextField = UITextField()

    public weak var delegate: VepayCVVFieldDelegate?

    public weak var nextField: UITextField? {
        didSet {
            field.returnKeyType = nextField == nil ? .done : .next
        }
    }


    // MARK: - Validation Propertys

    public private(set) var cvvReady: Bool = false {
        didSet {
            delegate?.cvvReadinessChanged(field: self, isReady: cvvReady)
        }
    }

    public private(set) var progress: CGFloat = .zero {
        didSet {
            delegate?.cvvProgressChanged(field: self, progress: progress)
        }
    }

    /// Digits that will set cvvProgress to 1.
    /// By default 3
    public var cvvMinCount: CGFloat = 3 {
        didSet {
            formatField(textField: field)
        }
    }

    /// How many symbols can be written in field.
    /// By default 3.
    /// America Express can be 4 digits
    public var cvvMaxCount: Int = 3

    // MARK: - Init

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public convenience init() {
        self.init(frame: .zero)
        setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

}


// MARK: - Get & Set

public extension VepayCVVField {

    /// Use this value to set You can set value with validation using this property
    var cvv: String {
        get {
            field.text ?? ""
        }
        set {
            field.text = String(newValue.numbersOnly().prefix(cvvMaxCount))
            formatField(textField: field)
        }
    }

}


// MARK: - Text Field Delegate

extension VepayCVVField: UITextFieldDelegate {

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        nextField?.becomeFirstResponder()
        return true
    }

}

// MARK: - CVV Field Delegate

extension VepayCVVField {

    @objc private func formatField(textField: UITextField) {
        let text = String(cvv.numbersOnly().prefix(cvvMaxCount))
        textField.text = text
        progress = min(CGFloat(text.count) / CGFloat(cvvMaxCount), 1)
    }

}


// MARK: - Setup

private extension VepayCVVField {

    private func setup() {
        field.placeholder = "000"
        field.font = .subHeading
        field.isSecureTextEntry = true
        field.delegate = self
        field.keyboardType = .numberPad
        field.returnKeyType = .done
        if #available(iOS 17.0, *) {
            field.textContentType = .creditCardSecurityCode
        }

        addSubview(field)
        field.translatesAutoresizingMaskIntoConstraints = false
        field.topAnchor.constraint(equalTo: topAnchor).isActive = true
        field.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        field.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        field.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        field.addTarget(self, action: #selector(formatField), for: .editingChanged)
    }

}


// MARK: - CVV Field Delegate

public protocol VepayCVVFieldDelegate: NSObject {

    func cvvReadinessChanged(field: VepayCVVField, isReady: Bool)
    func cvvProgressChanged(field: VepayCVVField, progress: CGFloat)

}
