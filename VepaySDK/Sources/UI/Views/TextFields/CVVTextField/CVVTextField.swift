//
//  CVVTextField.swift
//  VepaySDK
//
//  Created by Bohdan Hrozian on 3/26/25.
//

import UIKit

public final class VepayCVVTextField: VepayCommonTextField {


    // MARK: - Propertys

    private unowned var formatter: VepayTextFieldFormatter!

    /// Digits that will set cvvProgress to 1.
    /// By default 3
    public var cvvMinCount: Int = 3 {
        didSet {
            formatter.minLength = cvvMinCount
        }
    }

    /// How many symbols can be written in field.
    /// By default 3.
    /// America Express can be 4 digits
    public var cvvMaxCount: Int = 3 {
        didSet {
            formatter.maxLength = cvvMaxCount
        }
    }


    // MARK: - Setup

    public override func additionalSetup() {
        let formatter = VepayTextFieldFormatter(for: textField, allowedSymbols: .numbers, minLength: cvvMinCount, maxLength: cvvMaxCount)
        textField.formatter = formatter
        self.formatter = formatter
        
        textField.font = .subHeading
        textField.placeholder = "000"
        textField.isSecureTextEntry = true
        textField.keyboardType = .numberPad

        if #available(iOS 17.0, *) {
            textField.textContentType = .creditCardSecurityCode
        }
    }
    
}
