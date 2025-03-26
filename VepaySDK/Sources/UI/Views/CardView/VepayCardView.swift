//
//  VepayCardView.swift
//  VepaySDK
//
//  Created by Bohdan Hrozian on 17.07.2024.
//

import UIKit


@IBDesignable
public final class VepayCardView: UIView {

    
    // MARK: - Propertys

    public weak var delegate: VepayCardViewDelegate?

    private var fields: [VepayCommonTextField] {
        [cardNumberField, expirationDateField, cvvField].compactMap({ $0 })
    }


    // MARK: - Card Number

    @IBOutlet public private(set) weak var cardNumberField: VepayCardNumberField!

    /// Unmasked, Only numbers
    public var cardNumber: String {
        get {
            cardNumberField.cardNumbers
        }
        set {
            cardNumberField.cardNumbers = newValue
        }
    }

    /// Returns masked cardNumber (same as cardMask)
    /// You can change masking using cardNumberMask.
    /// For unmasked use cardNumber
    public var cardMasked: String {
        get {
            cardNumberField.text
        }
        set {
            cardNumberField.text = newValue
        }
    }


    // MARK: - Expriration Date

    @IBOutlet public private(set) weak var expirationDateLabel: UILabel?
    @IBOutlet public private(set) weak var expirationDateField: VepayDateTextField?


    /// if False removes expirationDateField from SuperView. Can not be undone
    @IBInspectable public var removeExpirtionDate: Bool {
        get {
            expirationDateField?.superview?.isHidden ?? true
        }
        set {
            if newValue {
                expirationDateLabel?.removeFromSuperview()
                expirationDateField?.removeFromSuperview()

                expirationDateField = nil
                updateFieldsReturnKeys()
            }
        }
    }

    /// If expirationDateField is removed, this value will be nil
    public var expirationDay: VepayDateTextField.Day? {
        get {
            expirationDateField?.day
        }
        set {
            expirationDateField?.day = newValue
        }
    }

    /// By deafult MMYY (same as formatter.dateFormat)
    /// Empty if the user has not entered a date yet
    /// If removeExpirtionDate == true, this value will be nil
    /// # Example: 1130
    public var expirationDateNumber: String? {
        expirationDateField?.dateNumbers
    }

    /// MM / YY (same as dateMask).
    /// Empty if the user has not entered a date yet
    /// For unmasked use expirationDate
    /// If expirationDateField is removed, this value will be nil
    public var expirationDate: String? {
        get {
            expirationDateField?.text
        }
        set {
            expirationDateField?.text = newValue ?? ""
        }
    }


    // MARK: - CVV

    @IBOutlet public private(set) weak var cvvField: VepayCVVTextField?
    @IBOutlet private weak var cvvFieldHolder: UIView?

    /// If False removes CVV Field from CardView. Can not be undone
    @IBInspectable public var removeCVV: Bool {
        get {
            cvvFieldHolder?.isHidden ?? true
        }
        set {
            if newValue {
                cvvFieldHolder?.superview?.removeFromSuperview()
                cvvField = nil
                updateFieldsReturnKeys()
            }
        }
    }

    /// Use this value to set You can set value with validation using this property
    /// If removeCVV == true, this value will be nil
    public var cvv: String! {
        get {
            cvvField?.text
        }
        set {
            cvvField?.text = newValue
        }
    }

    // MARK: - Bank ID

    @IBOutlet public private(set) weak var bankLogo: UIImageView!
    @IBOutlet public private(set) weak var paymentMethod: UIImageView!


    // MARK: - Card Scan

    @IBOutlet public private(set) weak var nfc: UIButton!
    @IBOutlet public private(set) weak var camera: UIButton!

    /// If True, when tapped on NFC fires delegate?.cardViewDidTapNFC
    public var overrideAddCardViaNFC: Bool = false
    /// If True, when tapped on Camera fires delegate?.cardViewDidTapCamera
    public var overrideAddCardViaCamera: Bool = false

    @IBInspectable public var hideAddCardViaNFC: Bool {
        get {
            nfc.isHidden
        }
        set {
            nfc.isHidden = newValue
        }
    }

    @IBInspectable public var hideAddCardViaCamera: Bool {
        get {
            camera.isHidden
        }
        set {
            camera.isHidden = newValue
        }
    }

    @IBAction private func addCard(method: UIButton) {
        if method == nfc {
            // NFC
            if overrideAddCardViaNFC {
                delegate?.cardViewDidTapNFC()
            } else {
                // TODO: add card via NFC.
                // Library method
            }
        } else {
            // Camera
            if overrideAddCardViaCamera {
                delegate?.cardViewDidTapCamera()
            } else {
                // TODO: add card via Camera.
            }
        }
    }


    // MARK: - Progress Propretrys

    public private(set) var ready: Bool = false {
        didSet {
            if ready != oldValue {
                delegate?.cardView(ready: ready)
            }
        }
    }


    // MARK: - Init

    public convenience init() {
        self.init(frame: .zero)
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

}


// MARK: - Main

public extension VepayCardView {

    func updateReady() {
        self.ready = fields.allSatisfy { $0.ready }
    }

}


// MARK: - CommonTextFieldDelegate

extension VepayCardView: CommonTextFieldDelegate {

    public func textFieldUpdated(_ field: VepayCommonTextField, text: String) { }
    
    public func textFieldReadyChanged(_ field: VepayCommonTextField, ready: Bool) {
        updateReady()
    }

    public func textFieldShouldReturn(_ field: VepayCommonTextField) -> Bool {
        if let currentIndex = fields.firstIndex(of: field), fields.indices.contains(currentIndex + 1) {
            fields[currentIndex + 1].textField.becomeFirstResponder()
        }
        return true
    }

}


// MARK: - VepayCardNumberFieldDelegate

extension VepayCardView: VepayCardNumberFieldDelegate {

    public func didIdentified(card: String, in textField: VepayCardNumberField, type: VepayCardType?, valid: Bool) {
        delegate?.cardView(number: card)
        cvvField?.cvvMaxCount = type?.maxCVV ?? 4
        paymentMethod.image = type?.paymentServiceLogo
    }

}


// MARK: - Show Not Ready

extension VepayCardView {
    
    /// When not ready, you can call this method to tell user
    public func showErrorNotReady() {
        let duration: TimeInterval = 0.12135

        func animate(field: UITextField?, placeholderOrText: Bool) {
            guard let field = field else { return }
            if placeholderOrText {
                UIView.transition(with: field, duration: duration, options: .transitionCrossDissolve) { [weak field] in
                    field?.attributedPlaceholder = .init(string: field?.placeholder ?? "", attributes: [ .foregroundColor: UIColor.strawberry])
                } completion: { [weak field] _ in
                    if field != nil {
                        UIView.transition(with: field!, duration: duration, options: .transitionCrossDissolve) { [weak field] in
                            let placeholder = field?.placeholder ?? ""
                            field?.attributedPlaceholder = nil
                            field?.placeholder = placeholder
                        }
                    }
                }
            } else {
                UIView.transition(with: field, duration: duration, options: .transitionCrossDissolve) { [weak field] in
                    field?.textColor = .strawberry
                } completion: { [weak field] _ in
                    if field != nil {
                        UIView.transition(with: field!, duration: duration, options: .transitionCrossDissolve) { [weak field] in
                            field?.textColor = .coal
                        }
                    }
                }
            }
        }

        if !cardNumberField.ready {
            animate(field: cardNumberField.textField, placeholderOrText: cardMasked.isEmpty)
            
        }

        if expirationDateField != nil, !expirationDateField!.ready {
            animate(field: expirationDateField!.textField, placeholderOrText: expirationDateField!.text.isEmpty)
        }

        if cvvField != nil, !cvvField!.ready {
            animate(field: cvvField!.textField, placeholderOrText: cvv.isEmpty)
        }
    }

}


// MARK: - Setup

extension VepayCardView {

    private func setup() {
        guard let view = UINib(nibName: "VepayCardView", bundle: .vepaySDK).instantiate(withOwner: self, options: nil).first as? UIView else { fatalError() }
        addSubview(view)
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        cardNumberField.delegate = self
        cardNumberField.defaultDelegate = self

        expirationDateField?.defaultDelegate = self

        cvvField?.defaultDelegate = self

        updateFieldsReturnKeys()
        setupCardShapeView()
        fields.forEach { $0.isLight = false }
        
        expirationDateField?.withGradient = false
        expirationDateField?.setMinHeight = false
        cvvField?.withGradient = false
        cvvField?.setMinHeight = false
    }
    
    private func updateFieldsReturnKeys() {
        cardNumberField.returnKeyType = expirationDateField == nil && cvvField == nil ? .done : .next
        expirationDateField?.returnKeyType = cvvField == nil ? .done : .next
        cvvField?.returnKeyType = .done
    }

    private func setupCardShapeView() {
        let cardDetailHolder = cardNumberField.superview!
        cardDetailHolder.layer.cornerRadius = 24
        cardDetailHolder.layer.borderWidth = 2
        cardDetailHolder.layer.borderColor = UIColor.coal24.cgColor
        cardDetailHolder.clipsToBounds = true

        cvvFieldHolder?.clipsToBounds = true
        cvvFieldHolder?.layer.cornerRadius = 16
        cvvFieldHolder?.superview?.layer.cornerRadius = 24
        cvvFieldHolder?.superview?.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]

        if #available(iOS 13.0, *) {
            cardDetailHolder.layer.cornerCurve = .continuous
            cvvFieldHolder?.layer.cornerCurve = .continuous
            cvvFieldHolder?.superview?.layer.cornerCurve = .continuous
        }
    }

}


// MARK: - VepayCardViewDelegate

public protocol VepayCardViewDelegate: NSObject {
    /// Determent by cardNumberProgress && expirationDateProgress && cvvFieldProgress.
    /// # Readiness calculated by Card Propertys that are editable
    func cardView(ready: Bool)

    /// Card number Changed. You can use this property for card identification (BIN checking)
    func cardView(number: String)
    func cardView(expirationDate: String, day: VepayDateTextField.Day?)
    func cardView(cvv: String)

    /// Fires only if overrideAddCardViaNFC = true
    func cardViewDidTapNFC()
    /// Fires only if overrideAddCardViaCamera = true
    func cardViewDidTapCamera()

}

public extension VepayCardViewDelegate {
    func cardView(number: String) { }
    func cardView(expirationDate: String, day: VepayDateTextField.Day?) { }
    func cardView(cvv: String) { }

    func cardViewDidTapNFC() { }
    func cardViewDidTapCamera() { }

}


@available(iOS 17, *)
#Preview {
    VepayCardView.init()
}
