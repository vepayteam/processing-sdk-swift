//
//  VepayFormattableTextField.swift
//  MoneyTransfer
//
//  Created by Bohdan Hrozian on 3/13/25.
//

import UIKit
import SwiftUI

public final class VepayFormattableTextField: UITextField {

    
    // MARK: - Propertys


    public var fieldReady: Bool = false {
        didSet {
            if oldValue != fieldReady {
                if let formatter = formatter as? VepayTextFieldFormatter {
                    if formatter.isValid != fieldReady {
                        formatter.isValid = fieldReady
                    }
                }
                defaultDelegate?.textFieldReadyChanged(self, ready: fieldReady)
            }
        }
    }

    public var bindingFieldReady: Binding<Bool> {
        get {
            .init(get: { [weak self] in
                self?.fieldReady ?? false
            }, set: { [weak self] newValue in
                self?.fieldReady = newValue
            })
        }
    }

    public func setWithFormattation(text: String) {
        self.text = formatter?.formatAndValidate(text: text) ?? text
    }

    private var previousBeforeLine: LocatedCharacter?
    private var previousAfterLine: LocatedCharacter?


    // MARK: - Delegate

    /// Don't use this propertys. Use maskingDelegate
    public override weak var delegate: (any UITextFieldDelegate)? {
        didSet {
            if let delegate, delegate !== self {
                self.formatter = (delegate as! VepayFormattableTextFieldFormatter)
                self.defaultDelegate = (delegate as! FormattableTextFieldDelegate)
                self.delegate = self
            }
        }
    }

    public var formatter: VepayFormattableTextFieldFormatter?
    /// VepayFormattableTextField inside CommonTextField will be connected to CommonTextField. Dont change it, use VepayCommonTextField.defaultDelegate instead
    public unowned var defaultDelegate: FormattableTextFieldDelegate?


    // MARK: - Init

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        delegate = self
    }

}


// MARK: - UITextFieldDelegate

extension VepayFormattableTextField: UITextFieldDelegate {

    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        defaultDelegate?.textFieldShouldBeginEditing?(textField) ?? true
    }

    public func textFieldDidBeginEditing(_ textField: UITextField) {
//        if let placeholderWhenEditing = placeholderWhenEditing {
//            textField.placeholder = placeholderWhenEditing
//        }
        defaultDelegate?.textFieldDidBeginEditing?(textField)
    }

    public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
//        if textField.placeholder == placeholderWhenEditing {
//            textField.placeholder = standardplaceholder
//        }
        return defaultDelegate?.textFieldShouldEndEditing?(textField) ?? true
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        defaultDelegate?.textFieldShouldReturn?(self) ?? true
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        previousAfterLine = nil
        previousBeforeLine = nil
        defaultDelegate?.textFieldDidEndEditing?(textField)
    }

}


// MARK: - Did Change Selection

extension VepayFormattableTextField {

    public func textFieldDidChangeSelection(_ textField: UITextField) {
        // Validate
        guard let start = textField.selectedTextRange?.start, start == textField.selectedTextRange?.end else {
            previousAfterLine = nil
            previousBeforeLine = nil
            return
        }

        // Propertys
        let location = textField.offset(from: textField.beginningOfDocument, to: start)

        let currentBeforeLine = location > .zero ? LocatedCharacter(location: location - 1, fullString: text!) : nil
        let currentAfterLine = location < text!.count ? LocatedCharacter(location: location, fullString: text!) : nil

        // Set Offset
        var offset: Int = .zero
        defer {
            previousAfterLine = currentAfterLine
            previousBeforeLine = currentBeforeLine

            if offset != .zero {
                if let newPosition = textField.position(from: start, offset: offset) {
                    textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
                }
            }
        }

        // Check Direction
        let movingToLeftOrToRight: Bool
        if let previousBeforeLineLocation = previousBeforeLine?.location,
           let currentBeforeLineLocation = currentBeforeLine?.location {
            movingToLeftOrToRight = currentBeforeLineLocation < previousBeforeLineLocation
        } else if let previousAfterLineLocation = previousAfterLine?.location,
           let currentAfterLineLocation = currentAfterLine?.location {
            movingToLeftOrToRight = currentAfterLineLocation < previousAfterLineLocation
        } else {
            // Move to closest
            var toLeftOffset = Int.zero
            if let currentBeforeLineLocation = currentAfterLine?.location {
                checkAfterLineToSelect(location: currentBeforeLineLocation, offset: &toLeftOffset)
            }

            var toRightOffset = Int.zero
            if let currentAfterLineLocation = currentAfterLine?.location {
                checkAfterLineToSelect(location: currentAfterLineLocation, offset: &toRightOffset)
            }
            offset = abs(toLeftOffset) < abs(toRightOffset) ? toLeftOffset : toRightOffset
            return
        }

        if movingToLeftOrToRight {
            // "123) |45" > "123|) 45"
            if formatter?.getSpacingCharactersCount(in: currentAfterLine?.character ?? "") == 1 {
                checkBeforeLineToSelect(location: location, offset: &offset)
            }
        } else {
            // "123|) 45" > "123) |45"
            if formatter?.getSpacingCharactersCount(in: currentBeforeLine?.character ?? "") == 1 {
                checkAfterLineToSelect(location: location, offset: &offset)
            }
        }

    }

    struct LocatedCharacter {
        let location: Int
        let character: String

        init(location: Int, fullString: String) {
            self.location = location
            self.character = String(fullString[fullString.index(fullString.startIndex, offsetBy: location)])
        }
    }

    private func checkAfterLineToSelect(location: Int, offset: inout Int) {
        let textCount = text!.count
        func _location() -> Int {
            location + offset
        }
        while _location() < textCount {
            let index = text!.index(text!.startIndex, offsetBy: _location())
            let count = formatter?.getSpacingCharactersCount(in: String(text![index])) ?? .zero
            if count > .zero {
                offset += count
            } else {
                break
            }
        }
    }

    private func checkBeforeLineToSelect(location: Int, offset: inout Int) {
        func _location() -> Int {
            location - 1 + offset
        }
        while _location() >= .zero {
            let index = text!.index(text!.startIndex, offsetBy: _location())
            let count = formatter?.getSpacingCharactersCount(in: String(text![index])) ?? .zero
            if count > .zero {
                offset -= count
            } else {
                break
            }
        }
    }

}


// MARK: - Should Change Characters

extension VepayFormattableTextField {

    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        if !(defaultDelegate?.textField?(textField, shouldChangeCharactersIn: range, replacementString: string) ?? true) {
            return false
        }

        // Validate input string
        let mustContinue = shouldChangeCharactersIn_mustContinue(textField: textField, range: range, string: string)
        guard mustContinue.0 else {
            return mustContinue.1!
        }

        // Updated Text
        guard let inputText = textField.changeCharactersIn(range: range, string: string) else { return true }

        var selectedCursosRange: UITextRange? = nil
        if let cursosRange = textField.selectedTextRange, textField.endOfDocument != cursosRange.start {
            selectedCursosRange = cursosRange
        }

        let previousTextCount = text?.count ?? .zero
        
        let newText = formatter?.formatAndValidate(text: inputText) ?? inputText
        let newTextCount = newText.count
        text = newText

        if let selectedCursosRange = selectedCursosRange {
            let offsetFromStart = textField.offset(from: textField.beginningOfDocument, to: selectedCursosRange.start)
            var lenght = newTextCount - previousTextCount
            var jumpOverSpacing: Int = .zero
            checkAfterLineToSelect(location: offsetFromStart, offset: &jumpOverSpacing)
            if lenght == .zero, selectedCursosRange.start != textField.endOfDocument {
                lenght = string.count
            }
            if let newPosition = textField.position(from: selectedCursosRange.start, offset: lenght + jumpOverSpacing) {
                textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
            }
        }

        defaultDelegate?.textFieldUpdated(self, text: newText)
        return false
    }

    /// - Parameter string: Changed string
    /// - Returns: continue "shouldChangeCharactersIn" flow. True - continue, False - stop; with False also returns second Bool
    private func shouldChangeCharactersIn_mustContinue(textField: UITextField, range: NSRange, string: String) -> (Bool, Bool?) {
        // Allow Pasting
        if textField.isPasting(in: range, string: string) {
            return (false, true)
        }

        // Allow backspace throw spacing character
        if string.isEmpty, formatter?.getSpacingCharatersCount(in: text!, start: range.location, lenght: 1) == 1 {
            var offsetFromLocation = 0
            while formatter!.getSpacingCharatersCount(in: text!, start: range.location - offsetFromLocation - 1, lenght: 1) == 1 {
                offsetFromLocation += 1
            }
            if let startPosition = textField.position(from: textField.beginningOfDocument, offset: range.location - offsetFromLocation) {
                textField.selectedTextRange = textField.textRange(from: startPosition, to: startPosition)
            }
            return (false, false)
        }
        return (true, nil)
    }

}


// MARK: - MaskingTextFieldDelegate

public protocol FormattableTextFieldDelegate: NSObject, UITextFieldDelegate {
    func textFieldUpdated(_ textField: VepayFormattableTextField, text: String)
    func textFieldReadyChanged(_ textField: VepayFormattableTextField, ready: Bool)
}
