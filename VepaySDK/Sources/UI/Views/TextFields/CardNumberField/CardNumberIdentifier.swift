//
//  VepayCardNumberIdentifier.swift
//  VepaySDK
//
//  Created by Bohdan Hrozian on 3/26/25.
//

import UIKit


// MARK: - Identifier

public final class VepayCardIdentifier: VepayCardNumberIdentifierInterface {

    public var allCardTypes: [VepayCardType] = VepayCardType.allTypes
    
    /// - Parameter cardNumbers: only numbers
    public func identifyAndValidate(number: String, completion: (VepayCardType?, Bool) -> Void) {
        let type = identifyType(number: number)
        completion(type, isValid(number: number, for: type))
    }
    
    /// - Parameter cardNumbers: only numbers
    public func identifyType(number: String) -> VepayCardType? {
        func matchesPattern(pattern: String) -> Bool {
            guard !pattern.isEmpty, let regex = try? NSRegularExpression(pattern: pattern) else {
                return false
            }

            let range = NSRange(location: 0, length: min(number.count, 8))
            let matches = regex.matches(in: number, range: range)
            return !matches.isEmpty
        }

        return allCardTypes.first(where: {
            matchesPattern(pattern: $0.pattern)
        })
    }

    public func isValid(number: String, for type: VepayCardType?) -> Bool {
        return (type?.validLengths ?? 13...19).contains(number.count) && (type?.usesLuhnAlgorithm ?? false ? isValidLuhn(number: number) : true)
    }
    
    /// - Parameter number: only numbers
    public func isValidLuhn(number: String) -> Bool {
        var sum = 0
        let reversedCharacters = number.reversed().map { String($0) }
        
        for (index, character) in reversedCharacters.enumerated() {
            guard let digit = Int(character) else { return false }
            
            if index % 2 == 1 {
                let doubled = digit * 2
                sum += doubled > 9 ? doubled - 9 : doubled
            } else {
                sum += digit
            }
        }
        
        return sum % 10 == 0
    }

}


// MARK: - VepayCardType

public struct VepayCardType: Equatable {

    // MARK: - Propertys

    public let paymentServiceLogo: UIImage?
    public let name: String
    public let pattern: String
    public let validLengths: ClosedRange<Int>
    public var maxCVV: Int
    public var usesLuhnAlgorithm: Bool = true

    public init(paymentServiceLogo: UIImage?, name: String, pattern: String, validLengths: ClosedRange<Int>, maxCVV: Int = 3, usesLuhnAlgorithm: Bool = true) {
        self.paymentServiceLogo = paymentServiceLogo
        self.name = name
        self.pattern = pattern
        self.validLengths = validLengths
        self.maxCVV = maxCVV
        self.usesLuhnAlgorithm = usesLuhnAlgorithm
    }
    
    // MARK: - Hardcoded

    public static var mir: VepayCardType {
        VepayCardType(
            paymentServiceLogo: UIImage(named: "MIR", in: .vepaySDK, compatibleWith: nil)!,
            name: "МИР",
            pattern: "^2[0-9]{6,}$",
            validLengths: 16...19
        )
    }

    public static var visa: VepayCardType {
        VepayCardType(
            paymentServiceLogo: UIImage(named: "Visa", in: .vepaySDK, compatibleWith: nil)!,
            name: "Visa",
            pattern: "^4[0-9]{6,}$",
            validLengths: 13...19
        )
    }

    public static var mastercard: VepayCardType {
        VepayCardType(
            paymentServiceLogo: UIImage(named: "Mastercard", in: .vepaySDK, compatibleWith: nil)!,
            name: "Mastercard",
            pattern: "^(5[1-5][0-9]{5}|222[1-9][0-9]{3}|22[3-9][0-9]{4}|2[3-6][0-9]{5}|27[01][0-9]{4}|2720[0-9]{3})$",
            validLengths: 16...16
        )
    }

    public static var unionPay: VepayCardType {
        VepayCardType(
            paymentServiceLogo: UIImage(named: "UnionPay", in: .vepaySDK, compatibleWith: nil)!,
            name: "Union Pay",
            pattern: "^(62|81|82)[0-9]{5,}$",
            validLengths: 16...19,
            usesLuhnAlgorithm: false
        )
    }

    public static var americanExpress: VepayCardType {
        VepayCardType(
            paymentServiceLogo: UIImage(named: "American Express", in: .vepaySDK, compatibleWith: nil)!,
            name: "American Express",
            pattern: "^3[47][0-9]{5,}$",
            validLengths: 15...19,
            maxCVV: 4
        )
    }

    public static var jcb: VepayCardType {
        VepayCardType(
            paymentServiceLogo: UIImage(named: "JCB", in: .vepaySDK, compatibleWith: nil)!,
            name: "jcb",
            pattern: "^(?:2131|1800|35[0-9]{2})[0-9]{3,}$",
            validLengths: 16...19
        )
    }

}


// MARK: - Support

extension VepayCardType {
    
    public static func == (lhs: VepayCardType, rhs: VepayCardType) -> Bool {
        return lhs.name == rhs.name
    }
    
    public static var allTypes: [VepayCardType] {
        return [.mir, .mastercard, .visa, .unionPay, .americanExpress, .jcb]
    }
    
}
