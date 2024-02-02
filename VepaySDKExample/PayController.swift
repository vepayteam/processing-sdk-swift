//
//  PaymentController.swift
//  VepaySDKExample
//
//  Created by Bohdan Hrozian on 23.01.2024.
//

import UIKit
import WebKit
import VepaySDK

final class PayController: UIViewController {


    // MARK: - Views

    private weak var payment: VepayPaymentController!

    @IBOutlet private weak var actionView: UIView!
    @IBOutlet private weak var makeTransfer: UIButton!

    private weak var loader: LoadingScreen?


    // MARK: - Propertys

    private var invoice: VepayInvoice!
    func configure(invoice: VepayInvoice) {
        self.invoice = invoice
    }

    private var sse: EventSource!

}


// MARK: - Life Cycle

extension PayController {

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        payment = segue.destination as? VepayPaymentController
        payment.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        actionView.layer.maskedCorners = .layerMaxXMinYCorner
        setActionView(animated: false)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        makeTransfer.layer.cornerRadius = makeTransfer.bounds.height / 2
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setActionView(hidden: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        setActionView()
    }

    private func setActionView(hidden: Bool = true, animated: Bool = true) {
        let animation: (() -> ()) = { [weak actionView] in
            if let actionView = actionView {
                actionView.transform = .init(translationX: .zero, y: hidden ? actionView.frame.height : .zero)
            }
        }
        animated ? UIView.animate(withDuration: 0.2, delay: .zero, options: [.curveEaseOut, .allowUserInteraction], animations: animation) : animation()
    }

}


// MARK: - VepayPaymentControllerDelegate

extension PayController: VepayPaymentControllerDelegate {
    
    func paymentController(isReadyToPay: Bool) {
        UIView.animate(withDuration: 0.2, delay: .zero, options: [.curveEaseOut, .allowUserInteraction]) { [weak makeTransfer] in
            makeTransfer?.tintColor = isReadyToPay ? .ice : .ice24
        }
    }

}


// MARK: - Pay

extension PayController {
    
    @IBAction private func pay() {
        if payment.validateReadinnes(), let card = payment.selectedCard {
            let loader = LoadingScreen()
            view.addSubview(loader)
            loader.frame = view.bounds
            loader.startAnimating()
            self.loader = loader

            VepayInvoicePayment(invoice: invoice, card: card, size: view.bounds.size, xUser: xUser, isTest: true)?.request(success: { [weak self] response in
                guard let self = self else { return }
                switch response.readable {
                case .ready(let url, let method, let postParameters):
                    start3DS(url: url, uuid: invoice.uuid!, method: method, postParameters: postParameters)
                case .pending:
                    print("\nPending")
                case .redirectingNotNeaded:
                    print("\nReadirect Not Neaded")
                }
                self.loader?.stopAnimationg()
            }, error: { [weak loader] in
                loader?.stopAnimationg()
                print($0)
            })
        }
    }

    private func start3DS(url: String, uuid: String, method: String, postParameters: [String: String]?) {
        Vepay3DSController.start(url: url, method: method, postParameters: postParameters) { [weak navigationController] controller in
            controller.startSSE(invoiceUUID: uuid, isTest: true)
            navigationController?.pushViewController(controller, animated: true)
        } failure: { error in
            print("\n3DS Error\n\(error)")
        }
    }

}
