//
//  VepayCommonTextField+Delegates.swift
//  MoneyTransfer
//
//  Created by Bohdan Hrozian on 3/18/25.
//

import UIKit

// MARK: - VepayCommonTextField + FormattableTextFieldDelegate

extension VepayCommonTextField: FormattableTextFieldDelegate {

    @objc open func textFieldUpdated(_ textField: VepayFormattableTextField, text: String) {
        defaultDelegate?.textFieldUpdated(self, text: text)
    }
    
    @objc open func textFieldReadyChanged(_ textField: VepayFormattableTextField, ready: Bool) {
        self.ready = ready
        updateGradientLineColor()
        defaultDelegate?.textFieldReadyChanged(self, ready: ready)
    }

    open func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        defaultDelegate?.textFieldShouldChangeCharacters(self) ?? true
    }
    
    open func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        defaultDelegate?.textFieldShouldBeginEditing(self) ?? true
    }

    open func textFieldDidBeginEditing(_ textField: UITextField) {
        defaultDelegate?.textFieldDidBeginEditing(self)
    }

    open func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        defaultDelegate?.textFieldShouldEndEditing(self) ?? true
    }

    open func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        defaultDelegate?.textFieldShouldReturn(self) ?? true
    }

    open func textFieldDidEndEditing(_ textField: UITextField) {
        defaultDelegate?.textFieldDidEndEditing(self)
    }
    
}


// MARK: - CommonTextFieldDelegate

public protocol CommonTextFieldDelegate: NSObject {
    func textFieldUpdated(_ field: VepayCommonTextField, text: String)
    func textFieldReadyChanged(_ field: VepayCommonTextField, ready: Bool)
    
    func textFieldShouldChangeCharacters(_ field: VepayCommonTextField) -> Bool
    func textFieldShouldBeginEditing(_ field: VepayCommonTextField) -> Bool
    func textFieldShouldEndEditing(_ field: VepayCommonTextField) -> Bool
    func textFieldShouldReturn(_ field: VepayCommonTextField) -> Bool

    func textFieldDidBeginEditing(_ field: VepayCommonTextField)
    func textFieldDidEndEditing(_ field: VepayCommonTextField)
}

public extension CommonTextFieldDelegate {
    func textFieldShouldChangeCharacters(_ field: VepayCommonTextField) -> Bool { true }
    func textFieldShouldBeginEditing(_ field: VepayCommonTextField) -> Bool { true }
    func textFieldShouldEndEditing(_ field: VepayCommonTextField) -> Bool { true }
    func textFieldShouldReturn(_ field: VepayCommonTextField) -> Bool { true }
    func textFieldDidBeginEditing(_ field: VepayCommonTextField) { }
    func textFieldDidEndEditing(_ field: VepayCommonTextField) { }

}
