//
//  VepayBankCardCell.swift
//  VepaySDK
//
//  Created by Bohdan Hrozian on 09.01.2024.
//

import UIKit

public final class VepayBankCardCell: UICollectionViewCell {

    public static let identifier = "VepayBankCardCell"
    
    @IBOutlet private weak var icon: UIImageView!
    @IBOutlet private weak var name: UILabel!

//    private var notSelectedConfiguration: ColorConfiguration!
//    private var selectedConfiguration: ColorConfiguration!

    private var selectionColor: UIColor = .coal
    public override var isSelected: Bool {
        willSet {
            if isNewCard {
                if newValue {
                    UIView.animate(withDuration: 0.6, delay: .zero, usingSpringWithDamping: 0.5, initialSpringVelocity: .zero, options: [.allowUserInteraction, .allowAnimatedContent], animations: { [weak icon] in
                        icon?.transform = .init(rotationAngle: -.pi)
                    }, completion: { [weak icon] _ in
                        icon?.transform = .identity
                    })
                }
            } else {
                UIView.animate(withDuration: 0.3, delay: .zero, options: .curveEaseOut) { [weak self] in
                    self?.layer.borderWidth = newValue ? 1.8 : 1
                    
                    if self?.layer.borderColor != nil {
                        self?.layer.borderColor = newValue ? self?.selectionColor.cgColor : UIColor.coal24.cgColor
                    }
                }
            }
        }
    }

    private var isNewCard = false

}


// MARK: - Configure

extension VepayBankCardCell {
    
    public func configure(with configuration: CellConfiguration) {
        layer.cornerRadius = 28
        self.icon.image = configuration.icon
        self.name.text = configuration.name.text

        layer.borderWidth = configuration.borderWidth
        backgroundColor = configuration.background
        layer.borderColor = configuration.border?.cgColor
        name.textColor = configuration.text

        self.selectionColor = configuration.selectionColor

        isNewCard = configuration.icon == UIImage(named: "addBank", in: .vepaySDK, compatibleWith: nil)
    }

}


// MARK: - Configuration Model

extension VepayBankCardCell {
    
    public struct CellConfiguration {

        init(icon: UIImage?, name: Name, text: UIColor = .coal, background: UIColor? = nil, border: UIColor? =  .coal24, borderWidth: CGFloat = 1, selectionColor: UIColor?) {
            self.icon = icon
            self.name = name
            self.text = text
            self.background = background
            self.border = border
            self.borderWidth = borderWidth
            self.selectionColor = selectionColor ?? .coal
        }


        static let newCard: CellConfiguration = .init(icon: UIImage(named: "addBank", in: .vepaySDK, compatibleWith: nil), name: .custom(text: "Новая карта"), text: .ice, background: .coal, border: nil, borderWidth: .zero, selectionColor: .coal)

        let icon: UIImage?
        let name: Name

        let text: UIColor
        let background: UIColor?
        let border: UIColor?
        let borderWidth: CGFloat

        let selectionColor: UIColor
//        let notSelected: ColorConfiguration
//        let selected: ColorConfiguration

        enum Name {
            case digits(last4: String)
            case custom(text: String)

            var text: String {
                switch self {
                case .digits(let last4):
                    return "•• \(last4)"
                case .custom(let text):
                    return text
                }
            }
        }

    }

    public struct ColorConfiguration {
//        let text: UIColor
//        let background: UIColor?
//        let border: UIColor?
//        let borderWidth: CGFloat
    }

}






