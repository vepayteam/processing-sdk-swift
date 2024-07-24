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
    /// You can set this property using setCard(remembered:)
    public private(set) var cardRemembered = true

    /// Hides option to save card
    public var hideRemberCard: Bool = false {
        didSet {
            remeberCardHolder?.isHidden = hideRemberCard
        }
    }
    

    // MARK: - Saved Cards

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

    
    // MARK: - Card View Quick Acess Public Propertys

    private var _cardNumber: String?
    /// This property just reference to VepayPaymentController.cardView.\$0.
    /// When creating this controller by programmaticly cardView not instantly inited, in order to avoid fatal error for first time settuping, you can use this property
    public var cardNumber: String {
        get {
            _cardNumber ?? cardView?.cardNumber ?? ""
        }
        set {
            if cardView == nil {
                _cardNumber = newValue
            } else {
                cardView.cardNumber = newValue
            }
        }
    }


    private var _expirationDate: (String, String)?
    /// This property just reference to VepayPaymentController.cardView.\$0.
    /// When creating this controller by programmaticly cardView not instantly inited, in order to avoid fatal error for first time settuping, you can use this property
    public var expirationDate: (String, String)? {
        get {
            _expirationDate ?? cardView?.expirationDate
        }
        set {
            if cardView == nil {
                _expirationDate = newValue
            } else {
                cardView.expirationDate = newValue
            }
        }
    }
    private var _cvv: String?
    /// This property just reference to VepayPaymentController.cardView.\$0.
    /// When creating this controller by programmaticly cardView not instantly inited, in order to avoid fatal error for first time settuping, you can use this property
    public var cvv: String {
        get {
            _cvv ?? cardView?.cvv ?? ""
        }
        set {
            if cardView == nil {
                _cvv = newValue
            } else {
                cardView.cvv = newValue
            }
        }
    }


    // MARK: - Card View Setup Propertys

    /// This property just reference to VepayPaymentController.cardView.\$0.
    /// When creating this controller by programmaticly cardView not instantly inited, in order to avoid fatal error for first time settuping, you can use this property
    /// When cardView will be added to controller, use this property in cardView (VepayPaymentController.cardView.\$0),because this property will be inactive and setted to nil
    public var showExpirtionDate: Bool?

    /// This property just reference to VepayPaymentController.cardView.\$0.
    /// When creating this controller by programmaticly cardView not instantly inited, in order to avoid fatal error for first time settuping, you can use this property
    /// When cardView will be added to controller, use this property in cardView (VepayPaymentController.cardView.\$0),because this property will be inactive and setted to nil
    public var showCVV: Bool?
    /// This property just reference to VepayPaymentController.cardView.\$0.
    /// When creating this controller by programmaticly cardView not instantly inited, in order to avoid fatal error for first time settuping, you can use this property
    /// When cardView will be added to controller, use this property in cardView (VepayPaymentController.cardView.\$0),because this property will be inactive and setted to nil
    public var overrideAddCardViaNFC: Bool?
    /// This property just reference to VepayPaymentController.cardView.\$0.
    /// When creating this controller by programmaticly cardView not instantly inited, in order to avoid fatal error for first time settuping, you can use this property
    /// When cardView will be added to controller, use this property in cardView (VepayPaymentController.cardView.\$0),because this property will be inactive and setted to nil
    public var overrideAddCardViaCamera: Bool?

    /// This property just reference to VepayPaymentController.cardView.\$0.
    /// When creating this controller by programmaticly cardView not instantly inited, in order to avoid fatal error for first time settuping, you can use this property
    /// When cardView will be added to controller, use this property in cardView (VepayPaymentController.cardView.\$0),because this property will be inactive and setted to nil
    public var hideAddCardViaNFC: Bool?
    /// This property just reference to VepayPaymentController.cardView.\$0.
    /// When creating this controller by programmaticly cardView not instantly inited, in order to avoid fatal error for first time settuping, you can use this property
    /// When cardView will be added to controller, use this property in cardView (VepayPaymentController.cardView.\$0),because this property will be inactive and setted to nil
    public var hideAddCardViaCamera: Bool?

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

        if hideRemberCard {
            remeberCardHolder?.isHidden = hideRemberCard
        }
        setCard(remembered: cardRemembered)

        if _cardNumber != nil {
            cardView.cardNumber = _cardNumber!
            _cardNumber = nil
        }
        if _expirationDate != nil {
            cardView.expirationDate = _expirationDate!
            _expirationDate = nil
        }
        if _cvv != nil {
            cardView.cvv = _cvv!
            _cvv = nil
        }

        if showExpirtionDate != nil {
            cardView.showExpirtionDate = showExpirtionDate!
            showExpirtionDate = nil
        }
        if showCVV != nil {
            cardView.showCVV = showCVV!
            showCVV = nil
        }
        if overrideAddCardViaNFC != nil {
            cardView.overrideAddCardViaNFC = overrideAddCardViaNFC!
            overrideAddCardViaNFC = nil
        }
        if overrideAddCardViaCamera != nil {
            cardView.overrideAddCardViaCamera = overrideAddCardViaCamera!
            overrideAddCardViaCamera = nil
        }
        if hideAddCardViaNFC != nil {
            cardView.hideAddCardViaNFC = hideAddCardViaNFC!
            hideAddCardViaNFC = nil
        }
        if hideAddCardViaCamera != nil {
            cardView.hideAddCardViaCamera = hideAddCardViaCamera!
            hideAddCardViaCamera = nil
        }
    }

}


// MARK: - Remember Card

extension VepayPaymentController {
    
    @objc private func tap(gesture: UITapGestureRecognizer) {
        view.endEditing(true)

        let location = gesture.location(in: remeberCardHolder)
        if remeberCardHolder.bounds.contains(location) {
            setCard(remembered: !cardRemembered)
        }
        
    }

    public func setCard(remembered: Bool) {
        cardRemembered = remembered
        let image = "Checkbox" + (remembered ? "Filled" : "Empty")
        UIView.transition(with: remeberCheckmark, duration: 0.16, options: [.curveEaseIn, .allowUserInteraction, .transitionCrossDissolve]) { [weak remeberCheckmark] in
            remeberCheckmark?.image = UIImage(named: image, in: .vepaySDK, compatibleWith: nil)
        }
    }

}
