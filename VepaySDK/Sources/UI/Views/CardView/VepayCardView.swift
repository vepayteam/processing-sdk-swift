//
//  VepayCardView.swift
//  VepaySDK
//
//  Created by Bohdan Hrozian on 17.07.2024.
//

import UIKit


@IBDesignable
public final class VepayCardView: UIView {


    public weak var delegate: VepayCardViewDelegate?


    // MARK: - Card Number

    @IBOutlet public private(set) weak var cardNumberField: VepayCardNumberField!

    public var notValidateMIRSystemExpirationDate = true

    /// Unmasked, Only numbers
    public var cardNumber: String {
        get {
            cardNumberField.card
        }
        set {
            cardNumberField.card = newValue
        }
    }

    /// Returns masked cardNumber (same as cardMask)
    /// You can change masking using cardNumberMask.
    /// For unmasked use cardNumber
    public var cardMasked: String {
        get {
            cardNumberField.cardMasked
        }
        set {
            cardNumberField.cardMasked = newValue
        }
    }


    // MARK: - Expriration Date

    @IBOutlet public private(set) weak var expirationDateLabel: UILabel?
    @IBOutlet public private(set) weak var expirationDateField: VepayExpirationDateField?


    /// if False removes expirationDateField from SuperView. Can not be undone
    @IBInspectable public var removeExpirtionDate: Bool {
        get {
            expirationDateField?.superview?.isHidden ?? true
        }
        set {
            if newValue {
                expirationDateLabel?.removeFromSuperview()
                expirationDateField?.removeFromSuperview()
                updateTotalProgress()
            }
        }
    }

    /// If expirationDateField is removed, this value will be nil
    public var expirationDate: VepayExpirationDateField.Day? {
        get {
            expirationDateField?.day
        }
        set {
            expirationDateField?.day = newValue
        }
    }

    /// MMYY.
    /// Empty if the user has not entered a date yet
    /// If removeExpirtionDate == true, this value will be nil
    /// # Example: 1130
    public var expirationDateRow: String! {
        get {
            expirationDateField?.dayRow
        }
        set {
            expirationDateField?.dayRow = newValue
        }
    }

    /// MM / YY (same as dateMask).
    /// Empty if the user has not entered a date yet
    /// For unmasked use expirationDate
    /// If expirationDateField is removed, this value will be nil
    public var expirationDateMasked: String! {
        get {
            expirationDateField?.dayMasked
        }
        set {
            expirationDateField?.dayMasked = newValue
        }
    }


    // MARK: - CVV

    @IBOutlet public private(set) weak var cvvField: VepayCVVField?
    @IBOutlet private weak var cvvFieldHolder: UIView?

    /// If False removes CVV Field from CardView. Can not be undone
    @IBInspectable public var removeCVV: Bool {
        get {
            cvvFieldHolder?.isHidden ?? true
        }
        set {
            if newValue {
                cvvFieldHolder?.removeFromSuperview()
                cardNumberField.superview!.superview!.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
                updateTotalProgress()
            }
        }
    }

    /// Use this value to set You can set value with validation using this property
    /// If removeCVV == true, this value will be nil
    public var cvv: String! {
        get {
            cvvField?.cvv
        }
        set {
            cvvField?.cvv = newValue
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

    /// true when totalProgress == 1.
    /// When changed fires delegate.cardView(ready:)
    /// # Value is normolized [0...1]
    public private(set) var ready: Bool = false {
        didSet {
            if ready != oldValue {
                delegate?.cardView(ready: ready)
            }
        }
    }
    
    /// true when cardNumberProgress == 1 && expirationDateProgress == 1 && cvvProgress == 1
    /// When changed fires delegate.cardView(progress:)
    /// # Value is normolized [0...1]
    public private(set) var totalProgress: CGFloat = .zero {
        didSet {
            delegate?.cardView(progress: totalProgress)
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


// MARK: - Card Number Field Delegate

extension VepayCardView: VepayCardNumberFieldDelegate {

    public func cardChanged(field: VepayCardNumberField, number: String) { }
    
    public func cardIdentificationChanged(field: VepayCardNumberField, service: VepayPaymentService?) {
        expirationDateField?.validateMinDay = service?.validateDate ?? false
        cvvField?.cvvMaxCount = service?.maxCVV ?? 3
        paymentMethod.image = service?.icon
    }

    public func cardReadinessChanged(field: VepayCardNumberField, isReady: Bool) { }

    public func cardProgressChanged(field: VepayCardNumberField, progress: CGFloat) {
        updateTotalProgress()
    }

}


// MARK: - Expiration Date Field Delegate

extension VepayCardView: VepayExpirationDateFieldDelegate {

    public func dateLessThenMinDate(field: VepayExpirationDateField, date: VepayExpirationDateField.Day) { }

    public func dateReadinessChanged(field: VepayExpirationDateField, isReady: Bool) { }

    public func dateProgressChanged(field: VepayExpirationDateField, progress: CGFloat) {
        updateTotalProgress()
    }

}


// MARK: - CVV Field Delegate

extension VepayCardView: VepayCVVFieldDelegate {

    public func cvvReadinessChanged(field: VepayCVVField, isReady: Bool) { }

    public func cvvProgressChanged(field: VepayCVVField, progress: CGFloat) {
        updateTotalProgress()
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

        if !cardNumberField.cardReady {
            animate(field: cardNumberField.field, placeholderOrText: cardMasked.isEmpty)
            
        }

        if !removeExpirtionDate, !expirationDateField!.dayReady {
            animate(field: expirationDateField!.field, placeholderOrText: expirationDateField!.dayMasked.isEmpty)
        }

        if !removeCVV, !cvvField!.cvvReady {
            animate(field: cvvField!.field, placeholderOrText: cvv.isEmpty)
        }
    }

}


// MARK: - Total Progress

private extension VepayCardView {

    private func updateTotalProgress() {
        var score = cardNumberField.progress
        var max: CGFloat = 1
        func addIfNeeded(progress: CGFloat!, _ needed: Bool) {
            if needed {
                score += progress
                max += 1
            }
        }
        addIfNeeded(progress: expirationDateField?.progress, !removeExpirtionDate)
        addIfNeeded(progress: cvvField?.progress, !removeCVV)

        totalProgress = score / max
        ready = totalProgress == 1
    }
    
}


// MARK: - Setup

extension VepayCardView {

    private func setup() {
        guard let view = UINib(nibName: "VepayCardView", bundle: .vepaySDK).instantiate(withOwner: self, options: nil).first as? UIView else { fatalError() }
        addSubview(view)
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        cardNumberField.nextField = expirationDateField?.field
        cardNumberField.delegate = self

        expirationDateField?.nextField = cvvField?.field
        expirationDateField?.delegate = self

        cvvField?.delegate = self

        setupCardShapeView()
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


// MARK: - Support

private extension VepayCardView {

    private func mask(text: String, mask: Substring) -> String {
        var result = ""
        var index = text.startIndex

        // Interate
        for character in mask where index < text.endIndex {
            if character == "X" {
                result.append(text[index])
                index = text.index(after: index)
            } else {
                result.append(character)
            }
        }

        return result
    }

    private func getNumbersIn(text: String) -> String {
        text.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
    }

}

// MARK: - VepayCardViewDelegate

public protocol VepayCardViewDelegate: NSObject {
    /// Determent by cardNumberProgress && expirationDateProgress && cvvFieldProgress.
    /// # Readiness calculated by Card Propertys that are editable
    func cardView(ready: Bool)

    /// - Parameter progress: TotalProgress of writen data. Normolized value: [0...1]
    func cardView(progress: CGFloat)
    /// - Parameter numberReadiness: Normolized value: [0...1]
    func cardView(numberReadiness: CGFloat)
    /// - Parameter expirationReadiness: Normolized value: [0...1]
    func cardView(expirationReadiness: CGFloat)
    /// - Parameter cvvFieldReadiness: Normolized value: [0...1]
    func cardView(cvvFieldReadiness: CGFloat)

    /// Card number Changed. This method can be used for card identification (BIN checking)
    func cardView(number: String)

    /// Fires only if overrideAddCardViaNFC = true
    func cardViewDidTapNFC()
    /// Fires only if overrideAddCardViaCamera = true
    func cardViewDidTapCamera()

}

public extension VepayCardViewDelegate {

    func cardView(progress: CGFloat) { }
    func cardView(numberReadiness: CGFloat) { }
    func cardView(expirationReadiness: CGFloat) { }
    func cardView(cvvFieldReadiness: CGFloat) { }

    func cardView(number: String) { }

    func cardViewDidTapNFC() { }
    func cardViewDidTapCamera() { }

}


@available(iOS 17, *)
#Preview {
    VepayCardView.init()
}
