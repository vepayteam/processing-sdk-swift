//
//  UITextField.swift
//  VepaySDK
//
//  Created by Bohdan Hrozian on 3/25/25.
//

import UIKit.UITextField

extension UITextField {
    
    func changeCharactersIn(range: NSRange, string: String) -> String? {
        if let text = text, let textRange = Range(range, in: text) {
            return text.replacingCharacters(in: textRange, with: string)
        } else {
            return nil
        }
    }

    func isPasting(in range: NSRange, string: String) -> Bool {
        range == NSRange(location: .zero, length: .zero) && string.allSatisfy ({ $0.isWhitespace })
    }

}
