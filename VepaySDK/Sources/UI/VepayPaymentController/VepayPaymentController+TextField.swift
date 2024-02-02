//
//  VepayPaymentViewController+TextField.swift
//
//
//  Created by Bohdan Hrozian on 28.12.2023.
//

import UIKit
//import VepaySDK


// MARK: - UITextViewDelegate

extension VepayPaymentController: UITextFieldDelegate {

    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        // Allow Pasting
        if range == NSRange(location: .zero, length: .zero) && string.allSatisfy ({ $0.isWhitespace }) {
            return true
        }

        // Updated Text
        guard let textFieldText = textField.text, let textRange = Range(range, in: textFieldText) else { return true }
        let updatedText = textFieldText.replacingCharacters(in: textRange, with: string)

        // If cursor isn't at the end, remember it's location
        var selectedCursosRange: UITextRange? = nil
        
        if let cursosRange = textField.selectedTextRange {
            let cursosOffset = textField.offset(from: textField.beginningOfDocument, to: cursosRange.start)
            if cursosOffset != textFieldText.count {
                selectedCursosRange = cursosRange
            }
        }

        // Mask
        set(text: updatedText, for: textField)

        // Set cursos if needed
        if let selectedCursosRange = selectedCursosRange {
            var offset = textField.offset(from: selectedCursosRange.start, to: selectedCursosRange.end)
            if offset == .zero { offset = 1 }
            if let to = textField.position(from: selectedCursosRange.end, offset: string == "" ? -offset : offset) {
                textField.selectedTextRange = textField.textRange(from: to, to: to)
            }
        }

        return false
    }

}


// MARK: - Set Text

extension VepayPaymentController {

    func set(text: String, for textField: UITextField) {
        let mask: String
        var isCVV: Bool = false
        if textField == cardNumber {
            mask = cardNumberMask
        } else if textField == cvv {
            isCVV = true
            mask = cvvMask
        } else {
            mask = validUntilMask
        }

        // Iteration Propertys
        let numbers = getNumbersIn(text: text, allowDot: isCVV)
        var result = ""
        var index = numbers.startIndex

        // Interate
        for character in mask where index < numbers.endIndex {
            if character == "X" {
                result.append(numbers[index])
                index = numbers.index(after: index)
            } else {
                result.append(character)
            }
        }

        if isCVV { // CVV
            handleCVV(future: result)
        } else if textField == validUntil { // Expiration
            check(expiration: result)
        } else { // Number
            textField.text = result
        }

        updateProgress(textField: textField)

    }

}


// MARK: - CVV

private extension VepayPaymentController {
    
    private func handleCVV(future: String) {
        if future.range(of: "[0-9]", options: .regularExpression) != nil {
            cvvTimer?.invalidate()
            var resultCharacters = Array(turnCurrentCVVIntoDots())
            var cvvCodeCharacters = Array(cvvCode)

            for (offset, character) in future.enumerated() {
                if resultCharacters.indices.contains(offset) {
                    let resultCharacterAtThisOffset = resultCharacters[offset]
                    if resultCharacterAtThisOffset != character {
                        cvvCodeCharacters[offset] = character
                        resultCharacters[offset] = character
                    }
                } else {
                    cvvCodeCharacters[offset] = character
                    resultCharacters.append(character)
                }
            }
            cvvCode = String(cvvCodeCharacters)
            cvv.text = String(resultCharacters)
            cvvTimer = .scheduledTimer(withTimeInterval: 1, repeats: false, block: turnChangedCVVCharactersIntoDots)
        } else if future.count < cvv.text!.count {
            cvv.text = future
        }
    }

    private func turnChangedCVVCharactersIntoDots(_ timer: Timer? = nil) {
        cvvTimer?.invalidate()
        var selectedCursosRange: UITextRange? = nil
        
        if let cursosRange = cvv.selectedTextRange {
            let cursosOffset = cvv.offset(from: cvv.beginningOfDocument, to: cursosRange.start)
            if cursosOffset != cvv.text!.count {
                selectedCursosRange = cursosRange
            }
        }

        self.cvv.text = turnCurrentCVVIntoDots()

        // Set cursos if needed
        if let selectedCursosRange = selectedCursosRange {
            var offset = cvv.offset(from: selectedCursosRange.start, to: selectedCursosRange.end)
            if offset == .zero { offset = 1 }
            if let to = cvv.position(from: selectedCursosRange.end, offset: -offset + 1) {
                cvv.selectedTextRange = cvv.textRange(from: to, to: to)
            }
        }
    }

    private func turnCurrentCVVIntoDots() -> String {
        cvv.text!.replacingOccurrences(of: "[0-9]", with: "•", options: .regularExpression)
    }

}



// MARK: - Expiration Date

private extension VepayPaymentController {

    private func check(expiration: String) {
        self.validUntil.attributedText = nil
        var ranges: [NSRange] = []
        if expiration.count > 1 {
            let month = Int(expiration.prefix(2))!
            if month > 12 {
                ranges.append(.init(location: .zero, length: 2))
            }

            if expiration.count == 7 {
                let year = Int(expiration.suffix(2))!
                if year < currentYear {
                    ranges.append(.init(location: expiration.count - 2, length: 2))
                } else if year == currentYear, month < currentMonth {
                    ranges = [.init(location: .zero, length: expiration.count)]
                }
            }
        }
        let attributed = NSMutableAttributedString(string: expiration, attributes: [.underlineColor: UIColor.strawberry])
        for range in ranges {
            attributed.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
        }
        self.validUntil.attributedText = attributed
    }

}


// MARK: - Setup & Support

extension VepayPaymentController {

    func setupTextFields() {
        cardNumber.delegate = self
        cardNumber.placeholder = cardNumberPlaceholder

        validUntil.delegate = self
        validUntil.placeholder = validUntilPlaceholder

        cvv.delegate = self
        cvv.placeholder = cvvPlaceholder

        setupCardNumberGradient()
    }

    private func setupCardNumberGradient() {
        cardNumberUnderline.layer.addSublayer(cardNumberUnderlineGradient)
        cardNumberUnderlineGradient.frame = cardNumberUnderline.bounds

        cardNumberUnderlineGradient.startPoint = .zero
        cardNumberUnderlineGradient.endPoint = CGPoint(x: 1, y: .zero)

        cardNumberUnderlineGradient.colors = [UIColor.coal.cgColor, UIColor.coal.withAlphaComponent(.zero).cgColor];
        updateProgress(textField: cardNumber)
    }

    /// - Returns: By Default false
    func getNumbersIn(text: String, allowDot: Bool = false) -> String {
        text.replacingOccurrences(of: "[^0-9\(allowDot ? "•" : "")]", with: "", options: .regularExpression)
    }

}
