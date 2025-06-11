//
//  VepayDateTextFormatter.swift
//  MoneyTransfer
//
//  Created by Bohdan Hrozian on 3/21/25.
//

import SwiftUI

public final class VepayDateTextFormatter: VepayTextFieldFormatter {


    // MARK: - Propertys

    /// https://en.wikipedia.org/wiki/List_of_date_formats_by_country
    /// "dd.MM.yyyy"
    public private(set) var textMask: String = "XX.XX.XXXX"
    private let spacingCharacters: String = RegexSymbols(arrayLiteral: .specSymbols, .whitespace).regex

    /// To change dateFormatter.dateFormat, use VepayDateTextFormatter.dateFormat (to also set textMask)
    public let dateFormatter: DateFormatter

    /// Writing date cant be greater than MaxDate
    public var maxDate: Date!
    /// Writing date cant be less than MinDate
    public var minDate: Date!

    public var dateFormat: String = "dd.MM.yyyy" {
        willSet {
            _willSet(dateFormat: newValue)
        }
    }

    private func _willSet(dateFormat: String) {
        dateFormatter.dateFormat = dateFormat
        textMask = dateFormat.replacingOccurrences(of: spacingCharacters, with: "X", options: .regularExpression)
    }


    // MARK: - Init

    public override init(isValid: Binding<Bool>, allowedCharactersExpression: String? = nil, notCountingCharacters: String? = nil, minLength: Int = .zero, maxLength: Int = 255) {
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        super.init(isValid: isValid)
    }

    public init(isValid: Binding<Bool>, dateFormatter: DateFormatter = DateFormatter(), dateFormat: String? = nil) {
        self.dateFormatter = dateFormatter
        super.init(isValid: isValid)
        _willSet(dateFormat: dateFormat ?? self.dateFormat)
    }

    public convenience init(for textField: VepayFormattableTextField, dateFormatter: DateFormatter = DateFormatter(), dateFormat: String? = nil) {
        self.init(isValid: textField.bindingFieldReady, dateFormatter: dateFormatter, dateFormat: dateFormat)
    }


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
        let current = isValid
        guard let date = date(from: text) else {
            if current {
                isValid = false
            }
            return
        }
        let new = (minDate == nil ? true : date > minDate) && (maxDate == nil ? true : date < maxDate)
        if current != new {
            isValid = new
        }
//        day > 0 && day <= 31
//        month > 0 && month <= 12
//        year >= 1900
    }

    public override func getSpacingCharactersCount(in text: String) -> Int {
        text.replacingOccurrences(of: spacingCharacters, with: "", options: .regularExpression).count
    }


    // MARK: - Helper

    public func date(from text: String) -> Date? {
        dateFormatter.date(from: text)
    }

    public func text(from date: Date) -> String {
        return dateFormatter.string(from: date)
    }

}
