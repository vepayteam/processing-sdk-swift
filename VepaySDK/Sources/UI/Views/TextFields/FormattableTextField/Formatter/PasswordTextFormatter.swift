//
//  PasswordTextFormatter.swift
//  MoneyTransfer
//
//  Created by Bohdan Hrozian on 3/18/25.
//

import UIKit

public final class VepayPasswordTextFormatter: VepayTextFieldFormatter {

    /// Digit & Lower Case & Upper Case, min 12 max 255, number
    private let predicate: NSPredicate = NSPredicate(format: "SELF MATCHES %@",  "^(?=.*[0-9])(?=.*[\\p{Lu}])(?=.*[\\p{Ll}])(?!.* ).{12,255}$")

    public override func validate(text: String) {
        let new = predicate.evaluate(with: predicate)
        if isValidGet() != new {
            isValidSet(new)
        }
    }

}
