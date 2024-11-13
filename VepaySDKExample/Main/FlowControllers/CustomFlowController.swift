//
//  CustomFlowController.swift
//  VepaySDK
//
//  Created by Bohdan Hrozian on 18.09.2024.
//

import UIKit
import VepaySDK

/// Here you can try your's custom flow
final class CustomFlowController: UIViewController {


    // MARK: - Proeprtys

    @IBOutlet private weak var sseURL: UITextField!
    @IBOutlet private weak var paste: UIButton!
    @IBOutlet private weak var start: UIButton!

}


// MARK: - Start

extension CustomFlowController {

    private func startPay() {
        guard !sseURL.text!.isEmpty else {
            return
        }

        // Initialize sse
        
    }

    // MARK: - Handle Pay
    
    private func handlePay(cardNumber: String, expirationDate: String, cvv: String) {
        
    }

}


// MARK: - SSE

extension CustomFlowController: Vepay3DSControllerDelegate {

    func sseUpdated(int: Int8?, string: String?) -> Bool {
        guard let string = string else {
            fatalError("int = \(int == nil ? "nil" : "\(int!)") | string = nil)")
        }

        var willStop = false
        let status = AppearFlowController.TransactionStatus(status: string)
        switch status {
        case .need3DS, .needAction, .done, .failed, .invoiceFailed:
            willStop = true
        default:
            willStop = false
        }
        let title = status.title

        presentAlert(title: title, body: "SSE Stoped \(willStop)", showGoToMainScreen: willStop)
        return willStop
    }
    
    func sseClosed() {
        presentAlert(title: "SSE Closed", body: nil, showGoToMainScreen: true)
    }

    private func presentAlert(title: String, body: String?, showGoToMainScreen: Bool) {
        DispatchQueue.main.async { [weak self] in
            let alert = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
            alert.addAction(.init(title: "Cancel", style: .cancel))
            if showGoToMainScreen {
                alert.addAction(.init(title: "Go To Main Screen", style: .default, handler: { [weak self] _ in
                    self?.navigationController?.popToRootViewController(animated: true)
                }))
            }
            self?.navigationController?.present(alert, animated: true)
        }
    }

}


// MARK: - Support

extension CustomFlowController {

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        sseURL.font = .subHeading
        paste.titleLabel?.font = .bodyLarge
        start.titleLabel?.font = .subHeading
        setupTapToDismiss()
    }


    // MARK: - Actions

    @IBAction private func tapped(button: UIButton) {
        if button == start {
            startPay()
        } else {
            pasteFromClipboard()
        }
    }

    private func pasteFromClipboard() {
        guard let url = UIPasteboard.general.string else { return }
        sseURL.text = url
    }

}
