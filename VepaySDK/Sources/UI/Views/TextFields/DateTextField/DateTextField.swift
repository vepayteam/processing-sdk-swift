//
//  NewDateTextField.swift
//  MoneyTransfer
//
//  Created by Bohdan Hrozian on 3/21/25.
//

import SwiftUI

public final class VepayDateTextField: VepayCommonTextField {

    
    // MARK: - Propertys

    public unowned var formatter: VepayDateTextFormatter! {
        willSet {
            textField.formatter = newValue
        }
    }

    public var date: Date? {
        get {
            formatter.date(from: text)
        } set {
            if let date = newValue {
                text = formatter.text(from: date)
            } else {
                text = ""
            }
        }
    }
    
    /// Use this value to get and set expirationDate. (MM, YY).
    /// nIl if the user has not yet entered a full date.
    /// For masked expiration use  expirationDateMasked
    public var day: Day? {
        get {
            guard let date = formatter.dateFormatter.date(from: text) else {
                return nil
            }
            let component = Calendar.current.dateComponents([.year, .month, .day], from: date)
            if let day = component.day, let month = component.month, let year = component.year {
                return .init(day: day, month: month, year: year)
            } else {
                return nil
            }
        }
        set {
            if let newValue, let date = Calendar.current.date(from: .init(year: newValue.year < 900 ? 2000 + newValue.year : newValue.year, month: newValue.month, day: newValue.day)) {
                text = formatter.text(from: date) 
            } else {
                text = ""
            }
        }
    }

    /// onlyNumbers in text (text.onlyNumbers())
    public var dateNumbers: String {
        text.onlyNumbers()
    }


    // MARK: - Setup

    public override func additionalSetup() {
        if #available(iOS 17.0, *) {
            textField.textContentType = .creditCardExpiration
        } else if #available(iOS 15.0, *) {
            textField.textContentType = .dateTime
        }
        textField.keyboardType = .numberPad
        
        textField.placeholder = "•• / ••"
        textField.font = .subHeading

        let formatter = VepayDateTextFormatter(for: textField)
        formatter.dateFormat = "MM / YY"
        self.formatter = formatter
    }

}


// MARK: - Day

public extension VepayDateTextField {
    
    struct Day {
        /// Starts from 1
        public let day: Int
        /// Starts from 1
        public let month: Int
        /// Starts from 1
        public let year: Int
        
        /// - Parameters:
        ///   - day: Starts from 1
        ///   - month: Starts from 1
        ///   - year: Starts from 1
        public init(day: Int = 1, month: Int, year: Int) {
            self.day = day
            self.month = month
            self.year = year
        }
    }

}
