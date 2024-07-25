//
//  VepayCardView.swift
//  VepaySDK
//
//  Created by Bohdan Hrozian on 17.07.2024.
//

import UIKit


@IBDesignable
public final class VepayCardView: UIView {


    // MARK: - Card Number

    @IBOutlet public private(set) weak var cardNumberField: UITextField!
    private let cardNumberFieldUnderline = CAGradientLayer()


    // MARK: - Valid Until

    @IBOutlet public private(set) weak var expirationDateLabel: UILabel?
    @IBOutlet public private(set) weak var expirationDateField: UITextField?
    /// MM / YY
    private let expirationDateMask = Substring("XX / XX")


    // MARK: - CVV

    @IBOutlet public private(set) weak var cvvField: UITextField?
    @IBOutlet private weak var cvvFieldHolder: UIView?


    // MARK: - Bank ID

    @IBOutlet public private(set) weak var bankLogo: UIImageView!
    @IBOutlet public private(set) weak var paymentMethod: UIImageView!


    // MARK: - Card Scan

    @IBOutlet public private(set) weak var nfc: UIButton!
    @IBOutlet public private(set) weak var camera: UIButton!

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
    
    // MARK: - Card Number Public Propertys

    /// User this value to get and set cardNumber. Digits only (without masking)
    /// For masked card number use cardNumberMasked
    public var cardNumber: String {
        get {
            getNumbersIn(text: cardNumberMasked)
        }
        set {
            cardNumberField.text = self.mask(text: getNumbersIn(text: newValue), mask: cardNumberMask)
            updateProgress(cardNumber: cardNumber)
        }
    }

    /// Returns masked cardNumber.
    /// You can change masking using  cardNumberMask.
    /// For unmasked use cardNumber
    public var cardNumberMasked: String {
        cardNumberField.text ?? ""
    }

    /// Mask used for CardNumber. X represents number
    public var cardNumberMask = Substring("XXXX XXXX XXXX XXXX XXXX")

    /// Use this propertys to specify when cardNumberProgress will be 1.
    /// # Example: if your service accepts only card with 16 digits, you can set 16
    public var cardNumberMinCount: CGFloat = 13 {
        didSet {
            updateProgress(cardNumber: cardNumber)
        }
    }

    /// Currently validating only by Lugh Alghorithm.
    public var validateCardNumber: Bool = true {
        didSet {
            updateProgress(cardNumber: cardNumber)
        }
    }


    // MARK: - Expiration Date Public Propertys

    private var currentMonth: Int8 = .zero
    private var currentYear: Int8 = .zero

    /// User this value to get and set expirationDate. (MM, YY).
    /// For masked expiration use  expirationDateMasked
    public var expirationDate: (String, String)? {
        get {
            let numbers = expirationDateRow
            return numbers.count == 4 ? (String(numbers.prefix(2)), String(numbers.suffix(2))) : nil
        }
        set {
            var result: String = ""
            if let date = newValue {
                result = String(getNumbersIn(text: date.0).suffix(2))

                let year = String(getNumbersIn(text: date.1).suffix(2))
                if !year.isEmpty {
                    result.append(contentsOf: " / \(year)")
                }
            }
            expirationDateField?.text = result
            set(expirationDate: result)
        }
    }

    /// MMYY
    /// # Example: 1130
    public var expirationDateRow: String {
        getNumbersIn(text: expirationDateMasked)
    }

    /// MM/YY.
    /// For unmasked use expirationDate
    public var expirationDateMasked: String {
        expirationDateField?.text ?? ""
    }
    
    /// if False removes expirationDateField from SuperView. Can not be undone
    @IBInspectable public var showExpirtionDate: Bool {
        get {
            !(expirationDateField?.superview?.isHidden ?? true)
        }
        set {
            if !newValue {
                expirationDateField?.superview?.removeFromSuperview()
                expirationDateLabel?.isHidden = true
                updateTotalProgress()
            }
        }
    }


    // MARK: - CVV Public Propertys

    /// Use this value to set You can set value with validation using this property
    public var cvv: String {
        get {
            cvvField?.text ?? ""
        }
        set {
            cvvField?.text = String(getNumbersIn(text: newValue).suffix(3))
            updateProgress(cvv: cvvField?.text?.count ?? .zero)
        }
    }

    /// How many symbols can be written in field. By default 3.  
    /// America Express can be 4 digits
    public var cvvAllowedCount: Int = 3

    /// Digits that will set cvvProgress to 1. By default 3
    public var cvvMinCount: CGFloat = 3 {
        didSet {
            updateProgress(cvv: cvvField?.text?.count ?? .zero)
        }
    }

    /// If False removes cvvField from SuperView. Can not be undone
    @IBInspectable public var showCVV: Bool {
        get {
            !(cvvFieldHolder?.isHidden ?? true)
        }
        set {
            if !newValue {
                cvvFieldHolder?.removeFromSuperview()
                cardNumberField.superview!.superview!.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
                updateTotalProgress()
            }
        }
    }


    // MARK: - Progress Public Propretrys

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

    /// # Value is normolized [0...1]
    public private(set) var cardNumberProgress: CGFloat = .zero {
        didSet {
            updateTotalProgress()
            delegate?.cardView(numberReadiness: cardNumberProgress)
        }
    }

    /// Automaticly updated when value seted using expirationDate or via user input
    /// # Value is normolized [0...1]
    public private(set) var expirationDateProgress: CGFloat = .zero {
        didSet {
            if showExpirtionDate {
                updateTotalProgress()
                delegate?.cardView(expirationReadiness: expirationDateProgress)
            }
        }
    }

    /// Automaticly updated when value seted using cvv or via user input
    /// # Value is normolized [0...1]
    public private(set) var cvvProgress: CGFloat = .zero {
        didSet {
            if showCVV {
                updateTotalProgress()
                delegate?.cardView(cvvFieldReadiness: cvvProgress)
            }
        }
    }


    // MARK: - Scan Public Propertys

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


    // MARK: - Init
    
    public weak var delegate: VepayCardViewDelegate?

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


// MARK: - Life Cycle

extension VepayCardView {

    private func setup() {
        let calendar = Calendar.current
        let date = Date()
        currentMonth = Int8("\(calendar.component(.month, from: date))".suffix(2))!
        currentYear = Int8("\(calendar.component(.year, from: date))".suffix(2))!

        guard let view = UINib(nibName: "VepayCardView", bundle: .vepaySDK).instantiate(withOwner: self, options: nil).first as? UIView else { fatalError() }
        addSubview(view)
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        cardNumberField.placeholder = "Введите номер карты"
        cardNumberField.font = .subHeading
        cardNumberField.delegate = self

        expirationDateField?.placeholder = "•• / ••"
        expirationDateField?.font = .subHeading
        expirationDateField?.delegate = self

        // cvvField
        cvvField?.placeholder = "000"
        cvvField?.font = .subHeading
        cvvField?.isSecureTextEntry = true
        cvvField?.delegate = self

        // cardNumberFieldUnderline
        cardNumberFieldUnderline.startPoint = .init(x: .zero, y: 0.5)
        cardNumberFieldUnderline.endPoint = .init(x: 1, y: 0.5)
        cardNumberFieldUnderline.colors = [UIColor.coal.cgColor, UIColor.coal.withAlphaComponent(.zero).cgColor]
        cardNumberFieldUnderline.locations = [0, 1]
        cardNumberField.superview!.layer.addSublayer(cardNumberFieldUnderline)

        setupCardShapeView()
    }

    private func setupCardShapeView() {
        let cardDetailHolder = cardNumberField.superview!.superview!
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

    public override func layoutSubviews() {
        super.layoutSubviews()
        cardNumberFieldUnderline.frame = .init(x: .zero, y: cardNumberField.frame.maxY + 11, width: cardNumberField.bounds.width, height: 1)
    }

}


// MARK: - TextField

extension VepayCardView: UITextFieldDelegate {
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Updated Text
        guard let textFieldText = textField.text, let textRange = Range(range, in: textFieldText) else {
            return true
        }
        let updatedText = textFieldText.replacingCharacters(in: textRange, with: string)
        
        // If cvvField return
        if textField == cvvField {
            updateProgress(cvv: updatedText.count)
            return updatedText.count <= cvvAllowedCount
        }
        
        // Allow Pasting
        if range == NSRange(location: .zero, length: .zero) && string.allSatisfy ({ $0.isWhitespace }) {
            return true
        }
        
        // If cursor isn't at the end, remember it's location
        var selectedCursosRange: UITextRange? = nil
        
        if let cursosRange = textField.selectedTextRange {
            let cursosOffset = textField.offset(from: textField.beginningOfDocument, to: cursosRange.start)
            if cursosOffset != textFieldText.count {
                selectedCursosRange = cursosRange
            }
        }
        
        let number = getNumbersIn(text: updatedText)
        
        if textField == cardNumberField {
            // Card Number
            textField.text = self.mask(text: number, mask: cardNumberMask)
            updateProgress(cardNumber: number)
        } else {
            // ExpirationDate
            let expirationDate = self.mask(text: number, mask: expirationDateMask)
            set(expirationDate: expirationDate)
        }
        
        if textField == cardNumberField {
            delegate?.cardView(number: textField.text!)
        }
        
        // Set cursos if needed
        if let selectedCursosRange = selectedCursosRange {
            var offset = textField.offset(from: selectedCursosRange.start, to: selectedCursosRange.end)
            if offset == .zero { offset = 1 }
            if let to = textField.position(from: selectedCursosRange.end, offset: string == "" ? -offset : offset) {
                textField.selectedTextRange = textField.textRange(from: to, to: to)
            }
        }
        
        return false
    }

}


// MARK: - Show Not Ready

extension VepayCardView {
    
    /// When not ready, you can call this method to tell user
    public func showErrorNotReady() {
        guard !ready else { return }
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
        if cardNumberProgress != 1 {
            animate(field: cardNumberField, placeholderOrText: cardNumber.isEmpty)
            
        }

        if expirationDateProgress != 1 {
            animate(field: expirationDateField, placeholderOrText: expirationDate == nil)
        }

        if cvvProgress != 1 {
            animate(field: cvvField, placeholderOrText: cvv.isEmpty)
        }
    }

}


// MARK: - Progress Supprt

private extension VepayCardView {
    
    // MARK: - Progress

    private func updateProgress(cvv: Int) {
        cvvProgress = calculateProgress(count: cvv, minCount: cvvMinCount)
    }

    private func updateProgress(cardNumber: String) {
        var progress = calculateProgress(count: cardNumber.count, minCount: cardNumberMinCount)

        if progress == 1, validateCardNumber, !VepayUtils.luhnCheck(cardNumber) {
            progress = -0.1
        }
        cardNumberProgress = progress
    }

    private func set(expirationDate: String) {
        var progress = calculateProgress(count: expirationDate.count, minCount: 4)
        self.expirationDateField?.attributedText = nil

        var ranges: [NSRange] = []
        if expirationDate.count > 1 {
            let month = Int(expirationDate.prefix(2))!
            if month > 12 {
                ranges.append(.init(location: .zero, length: 2))

            }
            
            if expirationDate.count == 7 {
                let year = Int(expirationDate.suffix(2))!
                if year < currentYear {
                    ranges.append(.init(location: expirationDate.count - 2, length: 2))
                } else if year == currentYear, month < currentMonth {
                    ranges.append(.init(location: .zero, length: expirationDate.count))
                }
            }
        }

        if ranges.isEmpty {
            expirationDateField?.text = expirationDate
        } else {
            progress = -1
            let attributed = NSMutableAttributedString(string: expirationDate, attributes: [.underlineColor: UIColor.strawberry])
            for range in ranges {
                attributed.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
            }
            expirationDateField?.attributedText = attributed
        }

        expirationDateProgress = progress
    }

    private func updateTotalProgress() {
        var score = cardNumberProgress
        var max: CGFloat = 1
        func addIfNeeded(progress: CGFloat, _ needed: Bool) {
            if needed {
                score += progress
                max += 1
            }
        }
        addIfNeeded(progress: expirationDateProgress, showExpirtionDate)
        addIfNeeded(progress: cvvProgress, showCVV)

        totalProgress = score / max
        ready = totalProgress == 1
    }

    private func calculateProgress(count: Int, minCount: CGFloat) -> CGFloat {
        min(CGFloat(count) / minCount, 1)
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
