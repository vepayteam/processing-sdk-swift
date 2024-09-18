//
//  VepayFlowController.swift
//  VepaySDKExample
//
//  Created by Bohdan Hrozian on 28.12.2023.
//

import UIKit
import VepaySDK

final class VepayFlowController: UIViewController {


    // MARK: - Proeprtys

    @IBOutlet private weak var xUser: UITextField!
    @IBOutlet private weak var create: UIButton!

    private var invoice: VepayInvoice!


    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        xUser.text = UserDefaults.standard.string(forKey: "XUserVepay")
        xUser.font = .subHeading
        create.titleLabel?.font = .bodyLarge
    }


    // MARK: - Actions

    @IBAction private func createInvoice() {
        start()
    }

}


// MARK: - Start

extension VepayFlowController {

    private func start() {
        guard !xUser.text!.isEmpty else { return }
        UserDefaults.standard.set(xUser.text, forKey: "XUserVepay")

        let statingInvoice = VepayInvoice(
            amountFractional: 10000,
            currency: "RUB",
            client: .init(
                fullName: "Терентьев Михаил Павлович",
                address: "г. Москва, дом 5",
                email: "user@mail.com",
                login: "ExampleLogin",
                phone: "+7999123456",
                zip: "234234234"),
            documentId: "КА-123/12121212",
            description: "Счет №1457")

        VepayInvoiceCreate(invoice: statingInvoice, xUser: xUser.text!, isTest: true).request(sessionHandler: networkManager, success: { [weak self] invoice in
            self?.invoice = invoice
            if let self = self {
                let pay = PayController.fromStoryboard()
                pay.handlePay = handlePay
                self.navigationController?.pushViewController(pay, animated: true)
            }
        }, error: {
            print("\nCreation Request Error\($0)")
        })
    }


    // MARK: - Handle Pay
    
    private func handlePay(cardNumber: String, expirationDate: String, cvv: String) {
        Vepay3DSController.paymentAndStart(uuid: invoice.uuid!, form: .init(card: .init(cardNumber: cardNumber, cardHolder: "holder", expires: expirationDate, cvc: cvv), size: view.bounds.size), xUser: xUser.text!, isTest: true, sessionHandler: networkManager) { [self] controller in
            controller.delegate = self
            controller.startSSE(invoiceUUID: invoice.uuid!, isTest: true)
            navigationController?.pushViewController(controller, animated: true)
        } pending: { [self] in
            presentAlert(title: "Pending", body: nil, showGoToMainScreen: false)
        } redirectingNotNeaded: { [self] in
            presentAlert(title: "Redirecting Not Neaded", body: nil, showGoToMainScreen: false)
        } failure: { [self] error in
            presentAlert(title: "Vepay Invoice Error", body: error.localizedDescription, showGoToMainScreen: false)
        }
    }

}

// MARK: - SSE

extension VepayFlowController: Vepay3DSControllerDelegate {

    func sseUpdated(status: VepaySDK.TransactionStatus) -> Bool {
        let title: String
        var willStop = true
        switch status {
        case .failed:
            title = "Failed"
        case .initiated:
            title = "Initiated"
            willStop = false
        case .processing:
            title = "In Progress"
            willStop = false
        case .done:
            title = "Done"
        case .pending:
            title = "Pending"
            willStop = false
        case .paid:
            title = "Paid"
            willStop = false
        case .invoiceFailed:
            title = "Invoice Failed"
        case .unknown(let int, let string):
            title = "Unknown Status: \(int != nil ? "\(int!)" : string ?? "Empty")"
        }
        
        presentAlert(title: "\(title)", body: "SSE Stoped \(willStop)", showGoToMainScreen: willStop)
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


// MARK: - Invoice Create

extension VepayFlowController {
    
    /// Производит создание счёта
    /// https://test.vepay.online/h2hapi/v1#/default/post_invoices
    private final class VepayInvoiceCreate: VepayBaseRequest, VepayRequest {

        typealias ResponseType = VepayInvoice

        init(invoice: VepayInvoice, xUser: String, isTest: Bool = false) {
            super.init(method: .post,
                       path: VepayUtils.h2hURL(endpoint: "invoices", isTest: isTest),
                       headers: ["X-User": xUser],
                       bodyEncodable: invoice)
        }

    }
    
}
