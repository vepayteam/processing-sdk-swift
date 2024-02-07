//
//  VepayPaymentController+CollectionView.swift
//  VepaySDK
//
//  Created by Bohdan Hrozian on 30.12.2023.
//

import UIKit
//import VepaySDK


// MARK: - UICollectionViewDelegateFlowLayout

extension VepayPaymentController: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {

        let cardNumber: String
        let cardExpiration: String
        let paymentIcon: UIImage?
        let bankLogo: UIImage?
        let bankColor: UIColor

        if savedCards.indices.contains(indexPath.row) {

            // Saved Card
            let card = savedCards[indexPath.row]

            cardNumber = card.number
            cardExpiration = card.expire

            paymentIcon = card.paymentSystem?.iconColored
            bankLogo = card.bank?.logo
            bankColor = card.bank?.color ?? .coal
        } else if collectionView.cellForItem(at: indexPath)?.isSelected == false {

            // Create New One
            cardNumber = ""
            cardExpiration = ""
            
            paymentIcon = nil
            bankLogo = nil
            bankColor = .coal
        } else {
            return true
        }

        set(text: cardNumber, for: self.cardNumber)
        set(text: cardExpiration, for: validUntil)
        cvvCode = "•••"
        set(text: "", for: cvv)
        paymentMethod.image = paymentIcon
        selectedCardLogo.image = bankLogo

        selectedCardIndex = indexPath
        UIView.animate(withDuration: 0.14, delay: .zero, options: [.allowUserInteraction, .curveLinear]) { [self] in
            arrowToCard.tintColor = bankColor
        }
        updateArrowToSelectedCard()

        let futureColors = [bankColor.cgColor, UIColor.coal24.cgColor]
        let previousColors = cardProgressionGradient.colors
        cardProgressionGradient.colors = futureColors

        let animation = CABasicAnimation(keyPath: "colors")
        animation.fromValue = previousColors
        animation.toValue = futureColors
        animation.duration = 0.16
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        cardProgressionGradient.add(animation, forKey: "animateGradient")
        return true
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateArrowToSelectedCard(scrollToItem: false)
    }
    
}


// MARK: - UICollectionViewDataSource

extension VepayPaymentController: UICollectionViewDataSource {
    

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        savedCardSCells.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VepayBankCardCell.identifier, for: indexPath) as! VepayBankCardCell
        cell.configure(with: savedCardSCells[indexPath.row])
        return cell
    }
    
}

// MARK: - Setup

extension VepayPaymentController {
    
    func setupCollectionView() {
        cardSelector.register(UINib(nibName: VepayBankCardCell.identifier, bundle: .vepaySDK), forCellWithReuseIdentifier: VepayBankCardCell.identifier)
        cardSelector.delegate = self
        cardSelector.dataSource = self
    }

}



