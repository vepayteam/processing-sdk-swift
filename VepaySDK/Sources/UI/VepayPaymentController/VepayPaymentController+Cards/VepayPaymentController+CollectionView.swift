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
        let expirationDate: String
        let paymentIcon: UIImage?
        let bankLogo: UIImage?
//        let bankColor: UIColor

        if savedCards.indices.contains(indexPath.row) {

            // Saved Card
            let card = savedCards[indexPath.row]

            cardNumber = card.number
            expirationDate = card.expire

            paymentIcon = card.paymentSystem?.icon
            bankLogo = card.bank?.logo
//            bankColor = card.bank?.color ?? .coal
        } else if collectionView.cellForItem(at: indexPath)?.isSelected == false {

            // Create New One
            cardNumber = ""
            expirationDate = ""
            
            paymentIcon = nil
            bankLogo = nil
//            bankColor = .coal
        } else {
            return true
        }

        cardView.cardNumber = cardNumber
        if expirationDate.count > 3 {
            cardView.expirationDate = .init(month: Int8(expirationDate.prefix(2))!, year: Int8(expirationDate.suffix(2))!)
        }
        cardView.cvv = ""
        cardView.paymentMethod?.image = paymentIcon
        cardView.bankLogo?.image = bankLogo

        selectedCardIndex = indexPath
//        UIView.animate(withDuration: 0.14, delay: .zero, options: [.allowUserInteraction, .curveLinear]) { [self] in
//            arrowToCard.tintColor = bankColor
//        }
        updateArrowToSelectedCard()

//        let futureColors = [bankColor.cgColor, UIColor.coal24.cgColor]
//        let previousColors = cardProgressionGradient.colors
//        cardProgressionGradient.colors = futureColors
//
//        let animation = CABasicAnimation(keyPath: "colors")
//        animation.fromValue = previousColors
//        animation.toValue = futureColors
//        animation.duration = 0.16
//        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
//        cardProgressionGradient.add(animation, forKey: "animateGradient")
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



