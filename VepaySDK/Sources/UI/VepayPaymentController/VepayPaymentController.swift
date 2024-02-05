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

    @IBOutlet private(set) weak var arrowToCard: UIView!
    @IBOutlet private weak var arrowOnTopOfTheArrowTop: NSLayoutConstraint!
    @IBOutlet private(set) weak var arrowToCardCenter: NSLayoutConstraint!
    
    // Card Deteil
    @IBOutlet private(set) weak var cardDetailHolder: UIView!
    @IBOutlet private(set) weak var selectedCardLogo: UIImageView!
    @IBOutlet private(set) weak var cardNumber: UITextField!
    let cardNumberPlaceholder = "Введите номер карты"
    let cardNumberMask = "XXXX XXXX XXXX XXXX XXXX"
    @IBOutlet private(set) weak var cardNumberUnderline: UIView!
    let cardNumberUnderlineGradient = CAGradientLayer()

    // Valid Until
    @IBOutlet private(set) weak var validUntil: UITextField!
    let validUntilPlaceholder = "•• / ••"
    let validUntilMask = "XX / XX"
    @IBOutlet private(set) weak var paymentMethod: UIImageView!

    @IBOutlet private(set) weak var cvv: UITextField!
    let cvvPlaceholder = "000"
    let cvvMask = "XXX"
    /// Timer is used for turning last character in • after 1 second
    var cvvTimer: Timer!
    /// cvvCode count must always be == 3
    lazy var cvvCode: String = "•••"

    // Remeber Card
    @IBOutlet private weak var remeberCardHolder: UIView!
    @IBOutlet private weak var remeberCheckmark: UIImageView!

    // Card Data Entry Progression
    let cardProgressionGradient = CAGradientLayer()
    // Value is normolized; in [0...1]
    lazy var cardNumberReadiness: Float = .zero {
        didSet {
            delegate?.cardNumberReadinessChanged(to: cardNumberReadiness)
        }
    }
    // Value is normolized; in [0...1]
    lazy var expirationReadiness: Float = .zero {
        didSet {
            delegate?.expirationReadinessChanged(to: expirationReadiness)
        }
    }
    // Value is normolized; in [0...1]
    lazy var cvvReadiness: Float = .zero {
        didSet {
            delegate?.cvvReadinessChanged(to: cvvReadiness)
        }
    }


    // MARK: - Propertys

    public lazy var savedCards: [VepayCard] = []
    public lazy var savedCardSCells: [VepayBankCardCell.CellConfiguration] = []
    public var overrideSavedCards: Bool = false
    public func set(cards: [VepayCard]) {
        savedCards = cards
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

    lazy var selectedCardIndex: IndexPath = [.zero, .zero]

    private(set) lazy var currentYear = Int("\(Calendar.current.component(.year, from: Date()))".suffix(2))!
    private(set) lazy var currentMonth = Int("\(Calendar.current.component(.month, from: Date()))")!

    public var dataEntryProgresssionAnimation = false

    
    // MARK: - Private Propertys

    private var rememberCard = false

    // MARK: - Public Propertys

    public weak var delegate: VepayPaymentControllerDelegate!
    public var isReadyToPay: Bool = false {
        didSet {
            if isReadyToPay != oldValue {
                delegate?.paymentController(isReadyToPay: isReadyToPay)
            }
        }
    }

    public var selectedCard: VepayPaymentCard? {
        if isReadyToPay, savedCards.indices.contains(selectedCardIndex.row) {
            return .init(card: savedCards[selectedCardIndex.row],
                             cvv: getNumbersIn(text: cvvCode))
        } else {
            return nil
        }
    }

    public func getCardNumber(unmasked: Bool) -> String {
        let card = cardNumber.text ?? ""
        return unmasked ? getNumbersIn(text: card) : card
    }

    public func getExpirationDate(unmasked: Bool) -> String {
        let expiration = validUntil.text ?? ""
        return unmasked ? getNumbersIn(text: expiration) : expiration
    }

    public func getCVV() -> String {
        cvv.text ?? ""
    }

}


// MARK: - Life Cycle

public extension VepayPaymentController {

    static func loadFromXib() -> VepayPaymentController {
        let name = "VepayPaymentController"
        return UIStoryboard(name: name, bundle: .vepaySDK).instantiateViewController(withIdentifier: name) as! VepayPaymentController
//        VepayPaymentController(nibName: "VepayPaymentController", bundle: .main)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }

        // Data
        getSavedCards()

        // UI
        setupTextFields()
        setupCollectionView()
        setupCardHolderView()
        arrowOnTopOfTheArrowTop.constant = 2.5
        cardProgressionGradient.type = .axial

        // Tap To Dismiss
        let tapToDismiss = UITapGestureRecognizer(target: self, action: #selector(tap(gesture:)))
        tapToDismiss.cancelsTouchesInView = false
        view.addGestureRecognizer(tapToDismiss)

        setRememberCheckmarkState(isOn: false)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        cardProgressionGradient.frame = cardDetailHolder.bounds
    }

}


// MARK: - Tap Gesture

extension VepayPaymentController {
    
    @objc private func tap(gesture: UITapGestureRecognizer) {
        view.endEditing(true)

        let location = gesture.location(in: remeberCardHolder)
        if remeberCheckmark.bounds.contains(location) {
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


// MARK: - validateReadinnes

extension VepayPaymentController {
    
    /// Showing error if needed
    /// - Returns: isReady
    public func validateReadinnes(useLuhnAlgorithm: Bool = true) -> Bool {
        isReadyToPay = cardNumberReadiness + expirationReadiness + cvvReadiness == 3

        var notReadyFields: [UITextField] = []

        // Card Number
        let validByLuhnAlgorithm = useLuhnAlgorithm || luhnCheck(getNumbersIn(text: cardNumber.text ?? ""))
        if cardNumberReadiness != 1 || !validByLuhnAlgorithm {
            notReadyFields.append(cardNumber)
        }

        // Expiration Date
        var validByExpirationDateChecker = true
        validUntil.attributedText?.enumerateAttributes(in: .init(location: .zero, length: validUntil.text?.count ?? .zero), using: { attributes, _, _ in
            if attributes[.underlineStyle] != nil {
                validByExpirationDateChecker = false
            }
        })

        if expirationReadiness != 1 || !validByExpirationDateChecker {
            notReadyFields.append(validUntil)
        }

        // CVV
        if cvvReadiness != 1 {
            notReadyFields.append(cvv)
        }

        if !notReadyFields.isEmpty {
            UIView.animate(withDuration: 0.1, delay: .zero, usingSpringWithDamping: 0.2,   initialSpringVelocity: .zero, options: .allowUserInteraction) {
                notReadyFields.forEach {
                    $0.transform = .init(translationX: -10, y: .zero)
                    $0.textColor = .cherry
                }
            } completion: { _ in
                UIView.animate(withDuration: 0.1, delay: .zero, usingSpringWithDamping: 0.2,   initialSpringVelocity: .zero, options: .allowUserInteraction) {
                    notReadyFields.forEach { $0.transform = .init(translationX: 13, y: .zero) }
                } completion: { _ in
                    UIView.animate(withDuration: 0.1, delay: .zero, usingSpringWithDamping: 0.1,   initialSpringVelocity: .zero, options: .allowUserInteraction) {
                        notReadyFields.forEach { 
                            $0.transform = .identity
                            $0.textColor = .coal
                        }
                    }
                }
            }
        }

        return isReadyToPay
    }

    /// https://gist.github.com/Edudjr/1f90b75b13017b5b0aec2be57187d119
    private func luhnCheck(_ number: String) -> Bool {
        var sum = 0
        let digitStrings = number.reversed().map { String($0) }

        for tuple in digitStrings.enumerated() {
            if let digit = Int(tuple.element) {
                let odd = tuple.offset % 2 == 1

                switch (odd, digit) {
                case (true, 9):
                    sum += 9
                case (true, 0...8):
                    sum += (digit * 2) % 9
                default:
                    sum += digit
                }
            } else {
                return false
            }
        }
        return sum % 10 == 0
    }
}



// MARK: - VepayPaymentControllerDelegate

public protocol VepayPaymentControllerDelegate: NSObject {
    func paymentController(isReadyToPay: Bool)

    /// Normolized value: [0...1]
    func cardNumberReadinessChanged(to value: Float)
    /// Normolized value: [0...1]
    func expirationReadinessChanged(to value: Float)
    /// Normolized value: [0...1]
    func cvvReadinessChanged(to value: Float)
}

public extension VepayPaymentControllerDelegate {
    func cardNumberReadinessChanged(to value: Float) { }
    func expirationReadinessChanged(to value: Float) { }
    func cvvReadinessChanged(to value: Float) { }
}
