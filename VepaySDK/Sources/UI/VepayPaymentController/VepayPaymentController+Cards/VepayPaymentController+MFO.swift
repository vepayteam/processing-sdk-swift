//
//  VepayPaymentController.swift
//  VepaySDK
//
//  Created by Bohdan Hrozian on 10.01.2024.
//

import UIKit
//import VepaySDK

extension VepayPaymentController {
    
    func getSavedCards() {
        guard !overrideSavedCards else { return }

        savedCards = [
            .init(id: 0, number: "4917610000000000", expire: "1127", holder: "q q", paymentSystem: "MASTERCARD"),
        ]

        savedCards[0].bank = .alpha

        savedCardSCells = savedCards.map {
            .init(icon: $0.bank?.icon, name: .digits(last4: String($0.number.suffix(4))), selectionColor: $0.bank?.color)
        }

        savedCardSCells.append(.newCard)

        cardSelector.reloadData()

        DispatchQueue.main.async { [self] in
            _ = self.collectionView(cardSelector, shouldSelectItemAt: selectedCardIndex)
            cardSelector.selectItem(at: selectedCardIndex, animated: true, scrollPosition: .centeredHorizontally)
        }

    }

}
