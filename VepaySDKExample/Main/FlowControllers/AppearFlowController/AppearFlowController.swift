//
//  AppearFlowController.swift
//  VepaySDK
//
//  Created by Bohdan Hrozian on 18.09.2024.
//

import UIKit
import VepaySDK

final class AppearFlowController: UIViewController {


    // MARK: - Proeprtys

    /// https://api.appeer.ru
    @IBOutlet private weak var urlBase: UITextField!
    @IBOutlet private weak var transactionID: UITextField!

    @IBOutlet private weak var xUser: UITextField!
    @IBOutlet private weak var accessToken: UITextField!

    @IBOutlet private weak var paste: UIButton!
    @IBOutlet private weak var start: UIButton!

    private let transactionStatus = UILabel()
    let defaultURL = "https://api.appeer.ru"

    var invoice: Invoice!

}


// MARK: - Start

extension AppearFlowController {

    private func startPay() {
        guard !urlBase.text!.isEmpty, !transactionID.text!.isEmpty, !xUser.text!.isEmpty, !accessToken.text!.isEmpty else {
            return
        }
        UserDefaults.standard.set(xUser.text, forKey: "XUserAppear")
        UserDefaults.standard.set(accessToken.text, forKey: "AcessTokenAppear")
        UserDefaults.standard.set(urlBase.text, forKey: "UrlBase")
        let pay = PayController.fromStoryboard()
        pay.handlePay = handlePay
        self.navigationController?.pushViewController(pay, animated: true)
    }

    // MARK: - Handle Pay
    
    private func handlePay(cardNumber: String, expirationDate: String, cvv: String) {
        let urlBase = urlBase.text!
        let xUser = xUser.text!
        let transactionID = transactionID.text!
        let accessToken = accessToken.text!
        let body = AppearCreateInvoiceBody(transactionId: transactionID, senderCardPan: cardNumber, senderCardExpMonth: String(expirationDate.prefix(2)), senderCardExpYear: String(expirationDate.suffix(2)), senderCardCvv: cvv)

        AppearCreateInvoice(urlBase: urlBase, xUser: xUser, accessToken: accessToken, body: body).request(sessionHandler: networkManager) { [self] invoice in
            self.invoice = invoice
            requestTransfer()
        } error: { [self] error in
            presentAlert(title: "Appear Invoice Error", body: error.description, showGoToMainScreen: true)
        }

    }

    private func requestTransfer() {
        let urlBase = urlBase.text!
        let transactionID = transactionID.text!
        let accessToken = accessToken.text!
        AppearGetTransfer(urlBase: urlBase, transactionId: transactionID, accessToken: accessToken).request(sessionHandler: networkManager) { [self] transfer in
            start3DS(confirmUrl: transfer.threeDs?.confirmUrl, attempts: 0)
        } error: { [self] error in
            presentAlert(title: "Appear Invoice Error", body: error.description, showGoToMainScreen: true)
        }
    }

    private func start3DS(confirmUrl: String?, attempts: Int ) {
        guard let confirmUrl = confirmUrl else {
            if attempts > 4 {
                presentAlert(title: "Appear Invoice Error", body: "confirmUrl == nil", showGoToMainScreen: true)
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [self] in
                    requestTransfer()
                }
            }
            return
        }
        let controller = Vepay3DSController()
        controller.show3DS(url: URL(string: confirmUrl)!)

        controller.delegate = self
        let url = URL(string: "\(self.urlBase.text!)/sse/\(transactionID.text!)")!
        controller.startSSE(url: url)
        navigationController?.pushViewController(controller, animated: true)
    }

}


// MARK: - SSE

extension AppearFlowController: Vepay3DSControllerDelegate {

    func sseUpdated(int: Int8?, string: String?) -> Bool {
        guard let string = string else {
            fatalError("int = \(int == nil ? "nil" : "\(int!)") | string = nil)")
        }

        let title: String
        var willStop = true
        switch TransactionStatus(status: string) {
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

        DispatchQueue.main.async { [self] in
            transactionStatus.text = "\(title)\nSSE \(willStop ? "Stoped" : "Continue")"
        }
        if willStop {
            presentAlert(title: title, body: "SSE Stoped", showGoToMainScreen: willStop)
        }
        return willStop
    }
    
    func sseClosed() {
        presentAlert(title: "SSE Closed", body: nil, showGoToMainScreen: true)
    }

    private func presentAlert(title: String, body: String?, showGoToMainScreen: Bool) {
        DispatchQueue.main.async { [weak self] in
            let alert = UIAlertController(title: title, message: body, preferredStyle: .actionSheet)
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

extension AppearFlowController {

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        urlBase.text = UserDefaults.standard.string(forKey: "UrlBase") ?? defaultURL
        xUser.text = UserDefaults.standard.string(forKey: "XUserAppear")
        accessToken.text = UserDefaults.standard.string(forKey: "AcessTokenAppear")
        urlBase.font = .subHeading
        transactionID.font = .subHeading
        paste.titleLabel?.font = .bodyLarge
        start.titleLabel?.font = .subHeading

        navigationController!.view.addSubview(transactionStatus)
        transactionStatus.layer.zPosition = 100
        transactionStatus.font = .subHeading
        transactionStatus.textColor = .coal
        transactionStatus.topAnchor.constraint(equalTo: navigationController!.view.safeAreaLayoutGuide.topAnchor).isActive = true
        transactionStatus.trailingAnchor.constraint(equalTo: navigationController!.view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        setupTapToDismiss()
    }


    // MARK: - Actions

    @IBAction private func tapped(button: UIButton) {
        if button == start {
            startPay()
        } else if button == paste {
            pasteFromClipboard()
        } else if button.tag == 1 {
            urlBase.text = ""
        } else if button.tag == 2 {
            transactionID.text = ""
        } else if button.tag == 3 {
            xUser.text = ""
        } else if button.tag == 4 {
            accessToken.text = ""
        }
    }
    
    /*
     https://api.appeer.ru/sse/qwenjkfl123401-1432fqw-fqwef
     */
    private func pasteFromClipboard() {
        guard let string = UIPasteboard.general.string else { return }
        if let separatorRange = string.ranges(of: "/").last {
            // Whole URL
            var urlBase = String(string[string.startIndex...separatorRange.lowerBound])
            urlBase = urlBase.replacingOccurrences(of: "/sse/", with: "")
            urlBase = urlBase.replacingOccurrences(of: "/transactions/", with: "")
            if !urlBase.contains("//") {
                urlBase = "https://\(urlBase)"
            }

            self.urlBase.text = urlBase
            transactionID.text = String(string[separatorRange.upperBound..<string.endIndex])
        } else {
            // Only UUID
            transactionID.text = string
        }
    }

}
