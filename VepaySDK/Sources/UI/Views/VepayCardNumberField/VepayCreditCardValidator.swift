//
//  CreditCardValidator.swift
//  VepaySDK
//
//  Created by Bohdan Hrozian on 15.09.2024.
//

import UIKit.UIImage

/// Based on
/// https://github.com/vitkuzmenko/CreditCardValidator/blob/master/Sources/CreditCardValidator/CreditCardValidator.swift
public struct VepayCreditCardIdentifier {

    /// Available credit card types
    private let services: [VepayPaymentService]

    public init(services: [VepayPaymentService] = VepayPaymentService.allHardcodedServices) {
        self.services = services
    }

    // MARK: - Identify & Validate

    public func identifyAndValidate(card: String) -> (VepayPaymentService?, Bool) {
        let card = card.numbersOnly()
        let type = identify(card: card)
        return (type, validate(card: card, type: type))
    }


    // MARK: - Identify
    
    /// - Parameter card: Only digits
    public func identify(card: String) -> VepayPaymentService? {
        return services.first { type in
            NSPredicate(format: "SELF MATCHES %@", type.regex)
                .evaluate(
                    with: card
                )
        }
    }


    // MARK: - Validate

    /// Validates card by type.
    /// Only digits.
    /// If type is nill just checks card count > 13
    public func validate(card: String, type: VepayPaymentService?) -> Bool {
        let isValidLength = type?.validNumberLength.contains(card.count) ?? (card.count > 13)
        let luhnAlgorithm = type?.usesLuhnAlgorithm ?? false ? luhnAlgorithm(card) : true
        return isValidLength && luhnAlgorithm
    }
    
    // MARK: - Luhn Check
    
    /// Card Validation
    /// Only digits
    /// https://gist.github.com/Edudjr/1f90b75b13017b5b0aec2be57187d119
    public func luhnAlgorithm(_ number: String) -> Bool {
        var sum = 0
        let digitStrings = number.reversed().map { String($0) }
        
        for tuple in digitStrings.enumerated() {
            if let digit = Int(tuple.element) {
                let odd = tuple.offset % 2 == 1
                
                switch (odd, digit) {
                case (true, 9):
                    sum += 9
                case (true, 0...8):
                    sum += (digit * 2) % 9
                default:
                    sum += digit
                }
            } else {
                return false
            }
        }
        return sum % 10 == 0
    }

}


// MARK: - VepayPaymentService

public class VepayPaymentService: Hashable {

    public init(name: String,
                icon: UIImage,
                regex: String,
                validateDate: Bool = false,
                maxCVV: Int = 3,
                usesLuhnAlgorithm: Bool = true,
                validNumberLength: ClosedRange<Int> = 16...16) {
        self.name = name
        self.icon = icon

        self.regex = regex

        self.validateDate = validateDate
        self.maxCVV = maxCVV

        self.usesLuhnAlgorithm = usesLuhnAlgorithm
        self.validNumberLength = validNumberLength
    }
    

    public let name: String
    public let icon: UIImage

    public let regex: String

    public let validateDate: Bool
    public let maxCVV: Int

    public let usesLuhnAlgorithm: Bool
    public let validNumberLength: ClosedRange<Int>
    /// Card date must be greater or equal to current date

    public class var allHardcodedServices: [VepayPaymentService] {
        [.mir, .masterCard, .visa, .unionPay, .americanExpress, .jcb]
    }

    public class var mir: VepayPaymentService {
        .init(name: "Мир", icon: UIImage(named: "MIR", in: .vepaySDK, compatibleWith: nil)!, regex: "^2[0-9]{6,}$", validateDate: true, validNumberLength: 16...19)
    }

    public class var masterCard: VepayPaymentService {
        .init(name: "Master Card", icon: UIImage(named: "Mastercard", in: .vepaySDK, compatibleWith: nil)!, regex: "^(?:5[1-5][0-9]{2}|222[1-9]|22[3-9][0-9]|2[3-6][0-9]{2}|27[01][0-9]|2720)[0-9]{12}$")
    }

    public class var visa: VepayPaymentService {
        .init(name: "Visa", icon: UIImage(named: "Visa", in: .vepaySDK, compatibleWith: nil)!, regex: "^4[0-9]{6,}$", validNumberLength: 13...16)
    }

    public class var americanExpress: VepayPaymentService {
        .init(name: "American Express", icon: UIImage(named: "AmericanExpress", in: .vepaySDK, compatibleWith: nil)!, regex: "^3[47][0-9]{5,}$", maxCVV: 4, validNumberLength: 15...15)
    }

    public class var unionPay: VepayPaymentService {
        .init(name: "Union Pay", icon: UIImage(named: "UnionPay", in: .vepaySDK, compatibleWith: nil)!, regex: "^62[0-5]\\d{13,16}$", usesLuhnAlgorithm: false, validNumberLength: 16...19)
    }
    
    public class var jcb: VepayPaymentService {
        .init(name: "JCB", icon: UIImage(named: "JCB", in: .vepaySDK, compatibleWith: nil)!, regex: "^(?:2131|1800|35[0-9]{3})[0-9]{3,}$", validNumberLength: 16...19)
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }

    public static func == (lhs: VepayPaymentService, rhs: VepayPaymentService) -> Bool {
        lhs.name == rhs.name
    }

}
