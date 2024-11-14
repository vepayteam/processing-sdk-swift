//
//  VepayExpirationDateField.swift
//  VepaySDK
//
//  Created by Bohdan Hrozian on 15.09.2024.
//

import UIKit.UIView


public final class VepayExpirationDateField: UIView {


    // MARK: - Public Propertys

    public let field: UITextField = UITextField()

    public weak var delegate: VepayExpirationDateFieldDelegate?

    public weak var nextField: UITextField? {
        didSet {
            field.returnKeyType = nextField == nil ? .done : .next
        }
    }

    private let dateMask = "XX / XX"


    // MARK: - Validation Propertys

    public private(set) var dayReady: Bool = false {
        didSet {
            delegate?.dateReadinessChanged(field: self, isReady: dayReady)
        }
    }

    public private(set) var progress: CGFloat = .zero {
        didSet {
            delegate?.dateProgressChanged(field: self, progress: progress)
        }
    }

    public var validateMinDay = true {
        didSet {
            validateDate()
        }
    }

    /// You can use validateMinDay to disable this default behavior
    /// # Defaul Behavior
    /// Checking is user written date less then current day
    public var minDay: Day = .init(month: .min, year: .min) {
        didSet {
            validateDate()
        }
    }

    public var maxDay: Day? = nil {
        didSet {
            validateDate()
        }
    }


    // MARK: - Init

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public convenience init() {
        self.init(frame: .zero)
        setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

}


// MARK: - Get & Set

public extension VepayExpirationDateField {

    /// Use this value to get and set expirationDate. (MM, YY).
    /// nIl if the user has not yet entered a full date.
    /// For masked expiration use  expirationDateMasked
    var day: Day? {
        get {
            let numbers = dayRow
            return numbers.count == 4 ? .init(month: Int8(numbers.prefix(2))!, year: Int8(numbers.suffix(2))!) : nil
        }
        set {
            field.text = newValue != nil ? "\(newValue!.month) / \(newValue!.year)" : ""
            formatField(textField: field)
        }
    }

    /// MMYY.
    /// Empty if the user has not entered a date yet
    /// # Example: 1130 || 0924
    var dayRow: String {
        get {
            dayMasked.numbersOnly()
        }
        set {
            dayMasked = newValue
        }
    }

    /// MM / YY (same as dateMask).
    /// Empty if the user has not entered a date yet
    /// For unmasked use expirationDate
    var dayMasked: String {
        get {
            field.text ?? ""
        }
        set {
            field.text = newValue
            formatField(textField: field)
        }
    }

}


// MARK: - Text Field Delegate

extension VepayExpirationDateField: UITextFieldDelegate {

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        nextField?.becomeFirstResponder()
        return true
    }

}


// MARK: - Text Field Formatation

extension VepayExpirationDateField {

    @objc private func formatField(textField: UITextField) {
        guard let inputText = textField.attributedText?.string ?? textField.text else { return }

        var targetCursorPosition = 0
        if let startPosition = textField.selectedTextRange?.start {
            targetCursorPosition = textField.offset(from: textField.beginningOfDocument, to: startPosition)
        }

        let numbers = inputText.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        targetCursorPosition -= inputText.count - numbers.count

        var result = ""
        var index = numbers.startIndex

        // iterate over the mask characters until the iterator of numbers ends
        for ch in dateMask where index < numbers.endIndex {
            if ch == "X" {
                // mask requires a number in this place, so take the next one
                result.append(numbers[index])

                // move numbers iterator to the next index
                index = numbers.index(after: index)

            } else {
                result.append(ch)
                targetCursorPosition += 1
            }
        }

        field.text = result
        DispatchQueue.main.async {
            if let targetPosition = textField.position(from: textField.beginningOfDocument, offset: targetCursorPosition) {
                textField.selectedTextRange = textField.textRange(from: targetPosition, to: targetPosition)
            }
        }

        validateDate()
    }

}


// MARK: - Date Validation

private extension VepayExpirationDateField {
    
    private func validateDate() {
        let numbers = dayRow
        var monthValid = true
        var yearValid = true

        if numbers.count > 1 {
            // Check Month
            let month = Int8(numbers.prefix(2))!
            monthValid = month > 0 && month < 13

            if numbers.count == 4, let year = Int8(numbers.suffix(2)) {
                // Check Year
                validateWholeDate(month: month, year: year, monthValid: &monthValid, yearValid: &yearValid)
            }
        }

        dayReady = monthValid && yearValid
        if !dayReady {
            drawError(monthValid: monthValid, yearValid: yearValid)
        }

        let progress = min(CGFloat(numbers.count) / 4, 1)
        self.progress = dayReady ? progress : progress - 0.1
    }

    private func validateWholeDate(month: Int8, year: Int8, monthValid: inout Bool, yearValid: inout Bool) {
        yearValid = year > 0

        // Check Min & Max Day
        if yearValid && monthValid {
            let day = Day(month: month, year: year)
            if validateMinDay, day < minDay {
                delegate?.dateLessThenMinDate(field: self, date: day)
                monthValid = false
                yearValid = false
            }
            if let maxDay = maxDay, maxDay < day {
                delegate?.dateGraterThenMaxDate(field: self, date: day)
                monthValid = false
                yearValid = false
            }
        }
    }

    private func drawError(monthValid: Bool, yearValid: Bool) {
        let text = field.attributedText?.string ?? dayMasked
        field.attributedText = nil
        

        let result = NSMutableAttributedString(string: text)

        func addUnderline(at range: NSRange) {
            result.addAttributes([
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .underlineColor: UIColor.strawberry,
            ], range: range)
        }

        if !monthValid, !yearValid {
            addUnderline(at: .init(location: .zero, length: result.length))
        } else if !monthValid {
            addUnderline(at: .init(location: .zero, length: 2))
        } else {
            addUnderline(at: .init(location: result.length - 2, length: 2))
        }

        field.attributedText = result
    }

}


// MARK: - Setup

private extension VepayExpirationDateField {

    private func setup() {
        field.delegate = self
        field.placeholder = "•• / ••"
        field.font = .subHeading
        field.delegate = self
        field.keyboardType = .numberPad
        if #available(iOS 17.0, *) {
            field.textContentType = .creditCardExpiration
        }

        let components = Calendar.current.dateComponents([.year, .month], from: Date())
        let year = Int8(components.year! % 100)
        minDay = .init(month: Int8(components.month!), year: year)

        addSubview(field)
        field.translatesAutoresizingMaskIntoConstraints = false
        field.topAnchor.constraint(equalTo: topAnchor).isActive = true
        field.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        field.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        field.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        field.addTarget(self, action: #selector(formatField), for: .editingChanged)
    }

}

// MARK: - Day

public extension VepayExpirationDateField {

    struct Day {

        public let month: Int8
        /// Year must be last 2 digits
        /// # Example: 24
        public let year: Int8
        
        /// - Parameters:
        ///   - year: Last 2 digits. 2024 = 24
        public init(month: Int8, year: Int8) {
            self.month = month
            self.year = year
        }

        static func < (lhs: Day, rhs: Day) -> Bool {
            return lhs.year < rhs.year || (lhs.year == rhs.year && lhs.month < rhs.month)
        }

    }

}


// MARK: - Expiration Date Field Delegate

public protocol VepayExpirationDateFieldDelegate: NSObject {

    func dateLessThenMinDate(field: VepayExpirationDateField, date: VepayExpirationDateField.Day)
    func dateGraterThenMaxDate(field: VepayExpirationDateField, date: VepayExpirationDateField.Day)

    func dateReadinessChanged(field: VepayExpirationDateField, isReady: Bool)
    func dateProgressChanged(field: VepayExpirationDateField, progress: CGFloat)
}

public extension VepayExpirationDateFieldDelegate {

    func dateGraterThenMaxDate(field: VepayExpirationDateField, date: VepayExpirationDateField.Day) { }

}

@available(iOS 17, *)
#Preview {
    VepayExpirationDateField()
}
