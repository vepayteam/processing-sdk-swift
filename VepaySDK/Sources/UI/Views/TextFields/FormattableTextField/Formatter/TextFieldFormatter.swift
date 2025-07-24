//
//  TextFieldFormatter.swift
//  MoneyTransfer
//
//  Created by Bohdan Hrozian on 3/17/25.
//

import SwiftUI

open class VepayTextFieldFormatter: VepayFormattableTextFieldFormatter {


    // MARK: - Propertys

    /// including (if minLenght = 0, true will be returned if text.count > 1)
    var minLength: Int
    /// including (if maxLength = 255, true will be returned if text.count <= 255)
    var maxLength: Int

    var allowedCharactersExpression: String?
    var notCountingCharacters: String?

    @Binding var isValid: Bool


    // MARK: - Init

    /// - Parameters:
    ///   - minLength: including (minLenght => 0)
    ///   - maxLength: including (maxLength = 255)
    public init(isValid: Binding<Bool>,
         allowedCharactersExpression: String? = nil,
         notCountingCharacters: String? = nil,
         minLength: Int = .zero, maxLength: Int = 255) {
        self._isValid = isValid
        self.allowedCharactersExpression = allowedCharactersExpression
        self.notCountingCharacters = notCountingCharacters
        self.minLength = minLength
        self.maxLength = maxLength
    }

    /// - Parameters:
    ///   - minLength: including (minLenght => 0)
    ///   - maxLength: including (maxLength = 255)
    public convenience init(isValid: Binding<Bool>,
                     allowedSymbols: RegexSymbols?,
                     notCountingCharacters: RegexSymbols? = nil,
                     minLength: Int = .zero, maxLength: Int = 255) {
        self.init(isValid: isValid, allowedCharactersExpression: allowedSymbols?.regex, notCountingCharacters: notCountingCharacters?.regex)
    }

    /// - Parameters:
    ///   - minLength: including (minLenght => 0)
    ///   - maxLength: including (maxLength <= 255)
    public convenience init(for textField: VepayFormattableTextField, allowedSymbols: RegexSymbols? = nil, notCountingCharacters: RegexSymbols? = nil, minLength: Int = .zero, maxLength: Int = 255) {
        self.init(isValid: textField.bindingFieldReady, allowedSymbols: allowedSymbols, notCountingCharacters: notCountingCharacters, minLength: minLength, maxLength: maxLength)
    }


    // MARK: - FormattableTextFieldFormatter

    public func getSpacingCharactersCount(in text: String) -> Int {
        .zero
    }

    public func getSpacingCharatersCount(in text: String, start: Int, lenght: Int) -> Int {
        guard start > -1, lenght + start > -1 else { return .zero }
        if let start = text.index(text.startIndex, offsetBy: start, limitedBy: text.endIndex), let end = text.index(start, offsetBy: lenght, limitedBy: text.endIndex) {
            let range = end > start ? start..<end : end..<start
            return getSpacingCharactersCount(in: String(text[range]))
        } else {
            return .zero
        }
    }

    public func formatAndValidate(text: String) -> String {
        let formatted = format(text: text)
        validate(text: formatted)
        return formatted
    }

    public func format(text: String) -> String {
        var text = String(text.prefix(maxLength))
        if let allowedCharactersExpression {
            text = text.replacingOccurrences(of: allowedCharactersExpression, with: "", options: .regularExpression)
        }
        return text
    }

    public func validate(text: String) {
        let count = (notCountingCharacters != nil ? text.replacingOccurrences(of: notCountingCharacters!, with: "") : text).count
        isValid = count >= minLength && count <= maxLength
    }

    public func getIfValidated(text: String) -> String? {
        let text = formatAndValidate(text: text)
        return isValid ? text : nil
    }
    
}


// MARK: - Support

public extension VepayTextFieldFormatter {

    struct RegexSymbols: OptionSet {
        public init(rawValue: Int8) {
            self.rawValue = rawValue
        }
        public let rawValue: Int8
        
        public static let russian = Self(rawValue: 1 << 0)
        public static let english = Self(rawValue: 1 << 1)
        public static let specSymbols = Self(rawValue: 1 << 2)
        public static let numbers = Self(rawValue: 1 << 3)
        public static let whitespace = Self(rawValue: 1 << 4)
        
        public static let russianSpecSymbolsNumbers: Self = [.russian, .specSymbols, .numbers]

        public var regex: String {
            var regex: String = "[^"
            if self.contains(.russian) {
                regex = "А-Яа-яёЁ"
            }
            if self.contains(.english) {
                regex.append("A-Za-z")
            }
            if self.contains(.numbers) {
                regex.append("0-9")
            }
            if self.contains(.specSymbols) {
                regex.append("!\"#$%&'()*+,-./:;<=>?@\\[\\\\\\]^_`{|}~")
            }
            if self.contains(.whitespace) {
                regex.append(" ")
            }
            return regex + "]"
        }
    }

}


// MARK: - FormattableTextFieldFormatter

public protocol VepayFormattableTextFieldFormatter {
    func format(text: String) -> String
    func formatAndValidate(text: String) -> String
    func validate(text: String)
    func getIfValidated(text: String) -> String?

    func getSpacingCharactersCount(in text: String) -> Int
    func getSpacingCharatersCount(in text: String, start: Int, lenght: Int) -> Int
}


// MARK: - VepayFormattableTextFieldFormatterTextPreparator

public protocol VepayFormattableTextFieldFormatterTextPreparator {
    func changeCharacter(in text: String, range: NSRange, replacementString: String) -> String?
}
