//
//  VepayAmountFormatter.swift
//  MoneyTransfer
//
//  Created by Bohdan Hrozian on 3/13/25.
//

import UIKit

public final class VepayCardNumberFormatter: VepayTextFieldFormatter {


    // MARK: - Propertys

    public var textMask: String = "XXXX XXXX XXXX XXXX XXX"
    private let spacingCharactes = RegexSymbols(arrayLiteral: .specSymbols, .whitespace).regex

    public var identifier: VepayCardNumberIdentifierInterface = VepayCardIdentifier()
    public weak var delegate: VepayCardNumberFormatterDelegate?

    
    // MARK: - Main

    public override func format(text: String) -> String {
        let numbers = text.onlyNumbers()
        var result = ""
        var index = numbers.startIndex

        for ch in textMask where index < numbers.endIndex {
            if ch == "X" {
                result.append(numbers[index])
                index = numbers.index(after: index)
            } else {
                result.append(ch)
            }
        }

        return result
    }

    public override func validate(text: String) {
        let number = text.onlyNumbers()
        identifier.identifyAndValidate(number: number) { [weak self] type, valid in
            guard let self else { return }

            if isValidGet() != valid {
                isValidSet(valid)
            }
            delegate?.didIdentified(card: number, type: type, valid: valid)
        }
    }

    public override func getSpacingCharactersCount(in text: String) -> Int {
        text.replacingOccurrences(of: spacingCharactes, with: "", options: .regularExpression).count
    }

}


// MARK: - VepayCardNumberFormatterDelegate

public protocol VepayCardNumberFormatterDelegate: NSObject {
    func didIdentified(card: String, type: VepayCardType?, valid: Bool)
}


// MARK: - VepayCardNumberIdentifier

public protocol VepayCardNumberIdentifierInterface {
    /// - Parameter cardNumbers: only numbers
    func identifyAndValidate(number: String, completion: @escaping (_ type: VepayCardType?, _ valid: Bool) -> Void)
}
