//
//  Resources+Support.swift
//
//
//  Created by Bohdan Hrozian on 28.12.2023.
//

import UIKit.UIColor


// MARK: - UIColor

extension UIColor {

    // Primary
    public static let coal = UIColor(named: "Coal", in: .vepaySDK, compatibleWith: nil)!
    public static let ice = UIColor(named: "Ice", in: .vepaySDK, compatibleWith: nil)!
    public static let limequat = UIColor(named: "Limequat", in: .vepaySDK, compatibleWith: nil)!
    public static let strawberry = UIColor(named: "Strawberry", in: .vepaySDK, compatibleWith: nil)!

    public static let cherry = UIColor(named: "Cherry", in: .vepaySDK, compatibleWith: nil)!

    public static let coal24 = coal.withAlphaComponent(0.24)
    public static let coal48 = coal.withAlphaComponent(0.48)
    public static let ice24 = ice.withAlphaComponent(0.24)
    public static let ice48 = ice.withAlphaComponent(0.48)
}


// MARK: - Bundle

extension Bundle {
    
    public class var vepaySDK: Bundle {
        return Bundle(for: VepayBaseRequest.self)
    }
    
}



