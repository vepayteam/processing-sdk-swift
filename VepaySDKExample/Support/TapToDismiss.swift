//
//  Extensions.swift
//  VepaySDK
//
//  Created by Bohdan Hrozian on 9/19/24.
//


import UIKit.UITapGestureRecognizer

extension UIViewController {
    
    func setupTapToDismiss() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(_dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    @objc private func _dismissKeyboard() {
        view.endEditing(true)
    }

}
