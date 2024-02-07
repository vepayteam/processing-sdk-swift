//
//  VepayBank.swift
//  VepaySDK
//
//  Created by Bohdan Hrozian on 10.01.2024.
//

import UIKit

public struct VepayBank {
    public let name: String
    public let icon: UIImage
    public let logo: UIImage
    public let color: UIColor

    public init(name: String, icon: UIImage, logo: UIImage, color: UIColor) {
        self.name = name
        self.icon = icon
        self.logo = logo
        self.color = color
    }

    public static let alpha = VepayBank(
        name: "Альфа Банк",
        icon: .init(named: "AlfaBank", in: .vepaySDK, compatibleWith: nil)!,
        logo: .init(named: "AlfaBankLogo", in: .vepaySDK, compatibleWith: nil)!,
        color: UIColor(named: "AlfaBankColor", in: .vepaySDK, compatibleWith: nil)!)
    public static let open = VepayBank(
        name: "Банк Открытие",
        icon: .init(named: "OpenBank", in: .vepaySDK, compatibleWith: nil)!,
        logo: .init(named: "OpenBankLogo", in: .vepaySDK, compatibleWith: nil)!,
        color: UIColor(named: "OpenBankColor", in: .vepaySDK, compatibleWith: nil)!)
    public static let tinkoff = VepayBank(
        name: "Тинькофф Банк",
        icon: .init(named: "TinkoffBank", in: .vepaySDK, compatibleWith: nil)!,
        logo: .init(named: "TinkoffBankLogo", in: .vepaySDK, compatibleWith: nil)!,
        color: UIColor(named: "TinkoffBankColor", in: .vepaySDK, compatibleWith: nil)!)

}
