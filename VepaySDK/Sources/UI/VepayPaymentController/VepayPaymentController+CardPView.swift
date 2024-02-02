//
//  VepayPaymentController+CardProgression.swift
//  VepaySDK
//
//  Created by Bohdan Hrozian on 15.01.2024.
//

import UIKit.UITextField
////import VepaySDK

// MARK: - Card Progression

extension VepayPaymentController {
    
    func updateProgress(textField: UITextField) {
        if textField == cardNumber {
            updateCardNumberGradient()
        } else if textField == cvv {
            cvvReadiness = Float(getNumbersIn(text: (textField.text ?? ""), allowDot: true).count) / 3
        } else {
            expirationReadiness = Float(getNumbersIn(text: textField.text ?? "").count) / 4
        }

        let whiteStartLocation = NSNumber(value: 0.1 + cardNumberReadiness * 0.7 + expirationReadiness)

        isReadyToPay = cardNumberReadiness + expirationReadiness + cvvReadiness == 3

        UIView.animate(withDuration: 0.1, delay: .zero, usingSpringWithDamping: 0.2, initialSpringVelocity: .zero) { [self] in
            cardProgressionGradient.locations = [0, whiteStartLocation, 2]
        }
    }

    private func updateCardNumberGradient() {
        let numbers = getNumbersIn(text: cardNumber.text ?? "")
        cardNumberReadiness = Float(numbers.count) / 13
        if cardNumberReadiness > 1 {
            cardNumberReadiness = 1
        }

        /// Start location
        /// Min: 0.5
        /// Max: 1
        let location = NSNumber(value: cardNumberReadiness * 0.5 + 0.5)
        cardNumberUnderlineGradient.locations = [0, location]
    }

}


// MARK: - Pointer To Selected Card

extension VepayPaymentController {

    func updateArrowToSelectedCard(animated: Bool = true, scrollToItem: Bool = true) {
        guard let cell = cardSelector.cellForItem(at: selectedCardIndex) else { return }
        let cellFrame = cardSelector.convert(cell.frame, to: view)
        let center: CGFloat
        if cellFrame.minX < -8 {
            center = -8 + cellFrame.width / 2
        } else if cellFrame.maxX > cardDetailHolder.frame.maxX + 32 {
            center = cardDetailHolder.frame.maxX + 32 - cellFrame.width / 2
        } else {
            center = cellFrame.midX
        }

        let animation: (() -> ()) = { [self] in
            arrowToCardCenter.constant = center
            if scrollToItem {
                cardSelector.scrollToItem(at: selectedCardIndex, at: .centeredHorizontally, animated: false)
            }
            view.layoutIfNeeded()
        }

        
//        animated ? UIView.animate(withDuration: 0.2, delay: .zero, usingSpringWithDamping: 0.2, initialSpringVelocity: .zero, animations: animation) : animation()

        animated ? UIView.animate(withDuration: 0.2, animations: animation) : animation()
    }

}


// MARK: - Setup

extension VepayPaymentController {

    func setupCardHolderView() {
        cardDetailHolder.layer.cornerRadius = 24
        validUntil.superview?.layer.cornerRadius = cardDetailHolder.layer.cornerRadius
        cvv.superview?.layer.cornerRadius = 16
        cvv.superview?.superview?.layer.cornerRadius = cardDetailHolder.layer.cornerRadius

        if #available(iOS 13.0, *) {
            cardDetailHolder.layer.cornerCurve = .continuous
            validUntil.superview?.layer.cornerCurve = cardDetailHolder.layer.cornerCurve
            cvv.superview?.superview?.layer.cornerCurve = cardDetailHolder.layer.cornerCurve
        }

        // Progression
        cardDetailHolder.layer.addSublayer(cardProgressionGradient)
        cardDetailHolder.bringSubviewToFront(cardDetailHolder.subviews[0])
        cardProgressionGradient.startPoint = .init(x: 0.5, y: .zero)
        cardProgressionGradient.endPoint = .init(x: 0.5, y: 1)
        cardProgressionGradient.colors = [UIColor.coal.cgColor, UIColor.coal24.cgColor]
    }

}
