//
//  String.swift
//  VepaySDK
//
//  Created by Bohdan Hrozian on 16.09.2024.
//

import Foundation.NSString

extension StringProtocol {

    func onlyNumbers(and: String = "") -> String {
        self.replacingOccurrences(of: "[^0-9\(and)]", with: "", options: .regularExpression)
    }

}
