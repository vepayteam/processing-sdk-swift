//
//  String.swift
//  VepaySDK
//
//  Created by Bohdan Hrozian on 16.09.2024.
//

import Foundation.NSString

extension StringProtocol {

    func numbersOnly() -> String {
        self.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
    }

}
