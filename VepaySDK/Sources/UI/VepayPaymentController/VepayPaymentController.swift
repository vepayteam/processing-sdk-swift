//
//  VepaySDKPayment.swift
//  
//
//  Created by Bohdan Hrozian on 28.12.2023.
//

import UIKit

// MARK: - Main

public final class VepayPaymentController: UIViewController {


    // MARK: - Views
    
    @IBOutlet public private(set) weak var scrollView: UIScrollView!

    @IBOutlet private(set) weak var cardSelector: UICollectionView!
    var selectedCardIndex: IndexPath = [.zero, .zero]

    @IBOutlet private(set) weak var arrowToCard: UIView!
    @IBOutlet private(set) weak var arrowToCardCenter: NSLayoutConstraint!

    @IBOutlet public private(set) weak var cardView: VepayCardView!

    // Remeber Card
    @IBOutlet private weak var remeberCardHolder: UIView!
    @IBOutlet private weak var remeberCheckmark: UIImageView!
    private var rememberCard = true

    /// Hides option to save card
    public var hideRemberCard: Bool = false {
        didSet {
            remeberCardHolder.isHidden = hideRemberCard
        }
    }


    // MARK: - Propertys

    /// Use set(cards:)
    public private(set) var savedCards: [VepayCard] = []
    /// Use set(cards:)
    public private(set) var savedCardSCells: [VepayBankCardCell.CellConfiguration] = [.newCard]
    public func set(cards: [VepayCard]) {
        let selectNewCard = savedCards.count < 2 && cardView.cardNumber == "" && cards.count > 0
        savedCards = cards
        savedCardSCells = savedCards.map {
            .init(icon: $0.bank?.icon, name: .digits(last4: String($0.number.suffix(4))), selectionColor: $0.bank?.color)
        }
        savedCardSCells.append(.newCard)

        cardSelector.reloadData()
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if selectNewCard  {
                let firstIndex = IndexPath(row: .zero, section: .zero)
                _ = self.collectionView(cardSelector, shouldSelectItemAt: firstIndex)
                cardSelector.selectItem(at: firstIndex, animated: true, scrollPosition: .centeredHorizontally)
            } else {
                selectedCardIndex = .init(row: savedCardSCells.count - 1, section: .zero)
                updateArrowToSelectedCard()
            }
        }
    }

}


// MARK: - Life Cycle

public extension VepayPaymentController {

    static func loadFromXib() -> VepayPaymentController {
        let name = "VepayPaymentController"
        return UIStoryboard(name: name, bundle: .vepaySDK).instantiateViewController(withIdentifier: name) as! VepayPaymentController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        setupCollectionView()

        // Tap To Dismiss
        let tapToDismiss = UITapGestureRecognizer(target: self, action: #selector(tap(gesture:)))
        tapToDismiss.cancelsTouchesInView = false
        view.addGestureRecognizer(tapToDismiss)

        setRememberCheckmarkState(isOn: false)
    }

}


// MARK: - Tap Gesture

extension VepayPaymentController {
    
    @objc private func tap(gesture: UITapGestureRecognizer) {
        view.endEditing(true)

        let location = gesture.location(in: remeberCardHolder)
        if remeberCardHolder.bounds.contains(location) {
            setRememberCheckmarkState(isOn: !rememberCard)
        }
        
    }

    private func setRememberCheckmarkState(isOn: Bool) {
        rememberCard = isOn
        let image = "Checkbox" + (isOn ? "Filled" : "Empty")
        UIView.transition(with: remeberCheckmark, duration: 0.16, options: [.curveEaseIn, .allowUserInteraction, .transitionCrossDissolve]) { [weak remeberCheckmark] in
            remeberCheckmark?.image = UIImage(named: image, in: .vepaySDK, compatibleWith: nil)
        }
    }

}
