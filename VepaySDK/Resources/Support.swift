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
//    public static let coal = UIColor(named: "Coal", in: .vepaySDK, compatibleWith: nil)!
//    public static let ice = UIColor(named: "Ice", in: .vepaySDK, compatibleWith: nil)!
//    public static let limequat = UIColor(named: "Limequat", in: .vepaySDK, compatibleWith: nil)!
//    public static let strawberry = UIColor(named: "Strawberry", in: .vepaySDK, compatibleWith: nil)!
//
//    public static let cherry = UIColor(named: "Cherry", in: .vepaySDK, compatibleWith: nil)!

    public static var coal24: UIColor {
        coal.withAlphaComponent(0.24)
    }

    public static var coal48: UIColor {
        coal.withAlphaComponent(0.48)
    }

    public static var ice24: UIColor {
        ice.withAlphaComponent(0.24)
    }

    public static var ice48: UIColor {
        ice.withAlphaComponent(0.48)
    }

}

extension UIFont {

    public static func interRegular(of size: CGFloat) -> UIFont {
        UIFont(name: "Inter-Regular", size: size)!
    }
    public static func interSemiBold(of size: CGFloat) -> UIFont {
        UIFont(name: "Inter-SemiBold", size: size)!
    }
    public static func interAppeerSemiBold(of size: CGFloat) -> UIFont {
        UIFont(name: "InterAppeer-SemiBold", size: size)!
    }

    /// Inter Appeer Semi Bold  20
    public static var subHeading: UIFont {
        interAppeerSemiBold(of: 20)
    }

    /// Inter-Regular 14
    public static var bodyLarge: UIFont {
        interRegular(of: 14)
    }

    /// Inter-Regular 12
    public static var bodySmall: UIFont {
        interRegular(of: 12)
    }

    /// Inter-SemiBold 12
    public static var bodySmallSemiBold: UIFont {
        interSemiBold(of: 12)
    }

}


// MARK: - Bundle

extension Bundle {
    
    public class var vepaySDK: Bundle {
        Bundle(for: VepayBaseRequest.self)
    }
    
}



