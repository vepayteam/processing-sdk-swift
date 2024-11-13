//
//  VepayPaymentController+Error.swift
//  VepaySDK
//
//  Created by Bohdan Hrozian on 11/13/24.
//

import UIKit

extension VepayPaymentController {
    
    /// - Parameters:
    ///   - durationToDisappear: Время сколько будет показываться сообщение. Если nil, то оно будет показано покуда не будет вручную убрано
    public func showError(message: String, durationToDisappear: TimeInterval?) {
        if let error = showingErrorMessage() {
            error.show(message: message, duration: durationToDisappear)
        } else {
            let error = ErrorMessage(frame: .zero)
            error.show(message: message, duration: durationToDisappear)
            UIView.transition(with: bottomStackView, duration: 0.161) {
                self.bottomStackView.insertArrangedSubview(error, at: .zero)
                self.scrollView.layoutIfNeeded()
            }
        }
    }

    public func hideError() {
        showingErrorMessage()?.hide()
    }

    private func showingErrorMessage() -> ErrorMessage? {
        return bottomStackView.arrangedSubviews.first as? ErrorMessage
    }

}


// MARK: - Error Message
extension VepayPaymentController {

    final class ErrorMessage: UIView {

        private let label = UILabel()
        private let image = UIImageView()

        private var timer: Timer?

        override init(frame: CGRect) {
            super.init(frame: frame)
            setup()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            setup()
        }

        func show(message: String, duration: TimeInterval?) {
            label.text = message
            timer?.invalidate()
            timer = nil

            if let duration = duration {
                timer = .scheduledTimer(timeInterval: duration, target: self, selector: #selector(hide), userInfo: nil, repeats: false)
            }
        }

        @objc func hide() {
            timer?.invalidate()
            timer = nil

            if let superview = superview {
                UIView.transition(with: superview, duration: 0.161) {
                    if let superview = superview as? UIStackView {
                        superview.removeArrangedSubview(self)
                    }
                    self.removeFromSuperview()
                }
            }
        }

        private func setup() {
            func add(subView: UIView, leading: NSLayoutXAxisAnchor, leadingConstant: CGFloat, top: NSLayoutYAxisAnchor, topConstant: CGFloat) {
                subView.translatesAutoresizingMaskIntoConstraints = false
                subView.leadingAnchor.constraint(equalTo: leading, constant: leadingConstant).isActive = true
                subView.topAnchor.constraint(equalTo: top, constant: topConstant).isActive = true
            }
            image.tintColor = .cherry
            if #available(iOS 13.0, *) {
                image.image = .init(named: "Error", in: .vepaySDK, with: nil)
            }
            add(subView: image, leading: self.leadingAnchor, leadingConstant: .zero, top: self.topAnchor, topConstant: .zero)
            image.widthAnchor.constraint(equalToConstant: 24).isActive = true
            image.heightAnchor.constraint(equalTo: image.widthAnchor).isActive = true
            image.bottomAnchor.constraint(greaterThanOrEqualTo: self.bottomAnchor).isActive = true

            label.tintColor = .cherry
            label.font = .bodyLarge
            add(subView: label, leading: image.trailingAnchor, leadingConstant: 8, top: self.topAnchor, topConstant: 1.5)
            label.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
            label.bottomAnchor.constraint(greaterThanOrEqualTo: self.bottomAnchor).isActive = true
        }
        
    }

}
