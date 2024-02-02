//
//  VepayBankSystem.swift
//  VepaySDK
//
//  Created by Bohdan Hrozian on 10.01.2024.
//

import UIKit.UIImage

// MARK: - Payment System

public enum VepayPaymentSystem {
    case visa
    case mastercard
    case mir
    case americanExpress
    case jcb

    // MARK: - TO DO
    public init?(name: String) {
        switch name {
        case "VISA":
            self = .visa
        case "MASTERCARD":
            self = .mastercard
        case "MIR":
            self = .mir
        case "AMERICAN EXPRESS":
            self = .americanExpress
        case "JCB":
            self = .jcb
        default:
            return nil
        }
    }

    // MARK: - TO DO
    /// Поставить картинки на которые должны
    public var iconColored: UIImage {
        let name: String
        switch self {
        case .visa:
            name = "Visa"
        case .mastercard:
            name = "Mastercard"
        case .mir:
            name = "MIR"
        case .americanExpress:
            name = "AmericanExpress"
        case .jcb:
            name = "JCB"
        }
        return UIImage(named: name, in: .vepaySDK, compatibleWith: nil)!
    }

}
