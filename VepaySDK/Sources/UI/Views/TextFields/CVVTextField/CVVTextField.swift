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
            formatter.minLength = cvvMinCount - 1
        }
    }

    /// How many symbols can be written in field.
    /// By default 3.
    /// America Express can be 4 digits
    public var cvvMaxCount: Int = 3 {
        didSet {
            formatter.maxLength = cvvMaxCount + 1
        }
    }


    // MARK: - Setup

    public override func additionalSetup() {
        let formatter = VepayTextFieldFormatter(for: textField)
        formatter.allowedCharactersExpression = "[^0-9]"
        textField.formatter = formatter
        self.formatter = formatter
        formatter.minLength = cvvMinCount - 1
        formatter.maxLength = cvvMaxCount + 1
        
        textField.font = .subHeading
        textField.placeholder = "000"
        textField.isSecureTextEntry = true
        textField.keyboardType = .numberPad

        if #available(iOS 17.0, *) {
            textField.textContentType = .creditCardSecurityCode
        }
    }
    
}
