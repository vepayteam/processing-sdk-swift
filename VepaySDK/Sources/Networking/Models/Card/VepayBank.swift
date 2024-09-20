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

}
