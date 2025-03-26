//
//  NewVepayCardNumberField.swift
//  VepaySDK
//
//  Created by Bohdan Hrozian on 3/26/25.
//

import UIKit


public final class VepayCardNumberField: VepayCommonTextField {


    // MARK: - Propertys

    public unowned var formatter: VepayCardNumberFormatter!
    public weak var delegate: VepayCardNumberFieldDelegate!

    /// Unmasked, Only numbers
    public var cardNumbers: String {
        get {
            text.onlyNumbers()
        }
        set {
            text = newValue
        }
    }

    
    // MARK: - Setup

    public override func additionalSetup() {
        let formatter = VepayCardNumberFormatter(for: textField)
        formatter.delegate = self
        textField.formatter = formatter
        self.formatter = formatter

        textField.keyboardType = .numberPad
        textField.textContentType = .creditCardNumber

        textField.font = .subHeading
        placeholder = "Введите номер карты"
    }

}


// MARK: - VepayCardNumberFormatterDelegate

extension VepayCardNumberField: VepayCardNumberFormatterDelegate {

    public func didIdentified(card: String, type: VepayCardType?, valid: Bool) {
        delegate?.didIdentified(card: card, in: self, type: type, valid: valid)
    }

}


// MARK: - VepayCardNumberFieldDelegate

public protocol VepayCardNumberFieldDelegate: NSObject {
    func didIdentified(card: String, in textField: VepayCardNumberField, type: VepayCardType?, valid: Bool)
}
