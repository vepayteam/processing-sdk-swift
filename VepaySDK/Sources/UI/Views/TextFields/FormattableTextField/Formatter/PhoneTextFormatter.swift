//
//  PhoneTextFormatter.swift
//  MoneyTransfer
//
//  Created by Bohdan Hrozian on 3/13/25.
//

import SwiftUI

public final class VepayPhoneTextFormatter: VepayTextFieldFormatter {


    // MARK: - Propertys

    public var textMask: String = CountryPhone.russia.mask
    public var prefix: String = CountryPhone.russia.prefix
    private let spacingCharactes = RegexSymbols(arrayLiteral: .specSymbols, .whitespace).regex

    public var currentCountry: CountryPhone = .russia {
        didSet {
            textMask = currentCountry.mask
            prefix = currentCountry.prefix
        }
    }

    // MARK: - Init

    public func recognizeAndFormat(number: String) -> String {
        // Recognize number
        let _number = number.onlyNumbers()
        
        let country = CountryPhone.allCases.first { country in
            return _number.hasPrefix(country.prefix.onlyNumbers())
        }
        if country == nil, (number.contains("+") || number.contains(" ") || number.contains("-")) {
            return number
        }

        let numbers = String(_number.dropFirst(country?.prefix.onlyNumbers().count ?? .zero)).onlyNumbers()

        var result = ""
        var index = numbers.startIndex

        if let textMask = country?.mask {
            for ch in textMask where index < numbers.endIndex {
                if ch == "X" {
                    result.append(numbers[index])
                    index = numbers.index(after: index)
                } else {
                    result.append(ch)
                }
            }
        }
        if index != numbers.endIndex {
            result += numbers[index...]
        }

        return result.isEmpty ? result : (country?.prefix ?? "") + result
    }

    // MARK: - Main

    public override func format(text: String) -> String {
        let numbers = (text.contains(prefix) ? String(text.dropFirst(prefix.count)) : text).onlyNumbers()
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
        if index != numbers.endIndex {
            result += numbers[index...]
        }

        return result.isEmpty ? result : prefix + result
    }

    public override func validate(text: String) {
        let new = currentCountry.validCount.contains(text.onlyNumbers().count)
        if isValidGet() != new {
            isValidSet(new)
        }
    }

    public override func getSpacingCharactersCount(in text: String) -> Int {
        text.replacingOccurrences(of: spacingCharactes, with: "", options: .regularExpression).count
    }

}


// MARK: - CountryPhone

extension VepayPhoneTextFormatter {
    
    public struct CountryPhone {
        let mask: String
        let prefix: String
        let validCount: ClosedRange<Int>

        init(mask: String = " (XXX) XXX XXXX", prefix: String, validCount: ClosedRange<Int>) {
            self.mask = mask
            self.prefix = prefix
            self.validCount = validCount
        }

        static var russia: Self { .init(prefix: "+7", validCount: 11...13) }
        static var tadzhikistan: Self { .init(prefix: "+992", validCount: 10...15) }

        static var allCases: [Self] = [
            .russia,
            .tadzhikistan
        ]
    }

}
