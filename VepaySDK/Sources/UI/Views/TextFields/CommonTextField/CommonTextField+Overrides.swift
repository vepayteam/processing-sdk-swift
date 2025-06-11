//
//  VepayCommonTextField+Overrides.swift
//  MoneyTransfer
//
//  Created by Bohdan Hrozian on 3/18/25.
//

import UIKit

extension VepayCommonTextField {


//    override var isFirstResponder: Bool {
//        get {
//            textField.isFirstResponder
//        }
//        set {
//            _ = (newValue ? textField.becomeFirstResponder : textField.resignFirstResponder)()
//        }
//    }
//    @discardableResult override func becomeFirstResponder() -> Bool {
//        super.becomeFirstResponder()
//        textField.becomeFirstResponder()
//        return true
//    }
//
//    @discardableResult override func resignFirstResponder() -> Bool {
//        super.resignFirstResponder()
//        textField.resignFirstResponder()
//        return true
//    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        gradient.frame.origin.y = intrinsicContentSize.height - 1
        gradient.frame.size.width = bounds.width
    }

    open override var intrinsicContentSize: CGSize {
        let size = textField.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        var height: CGFloat = size.height //+ textFieldTop.constant

        if setMinHeight {
            // Bottom Gradient
            height += 13
            height = max(height, 44)
        }
        return CGSize(width: size.width,
                      height: height)
    }

}
