//
//  PaymentController.swift
//  VepaySDKExample
//
//  Created by Bohdan Hrozian on 23.01.2024.
//

import WebKit
import VepaySDK
//import LDSwiftEventSource


final class PayController: UIViewController {


    // MARK: - Views

    private(set) weak var payment: VepayPaymentController!

    @IBOutlet private weak var actionView: UIView!
    @IBOutlet private weak var makeTransfer: UIButton!

    private weak var loader: LoadingScreen?


    // MARK: - Propertys

//    public var overrideSavedCards: Bool = false {
//        didSet {
//            payment?.overrideSavedCards = overrideSavedCards
//        }
//    }

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
        payment.expirationDate = ("11", "24")
        payment.cardNumber = "4917610000000000"
        payment.cvv = "333"
//        payment.hideAddCardViaNFC = true
//        payment.hideAddCardViaCamera = true
//        payment.showCVV = false
//        payment.showExpirtionDate = false
//        payment.hideRemberCard = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        actionView.layer.maskedCorners = .layerMaxXMinYCorner
        setActionView(animated: false)
        payment.cardView.delegate = self
        cardView(ready: payment.cardView.ready)
//        payment.cardView.hideAddCardViaNFC = true
//        payment.cardView.hideAddCardViaCamera = true
//        payment.cardView.showCVV = false
//        payment.cardView.showExpirtionDate = false
//        payment.hideRemberCard = true
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


// MARK: - VepayCardViewDelegate

extension PayController: VepayCardViewDelegate {
    
    func cardView(ready: Bool) {
        UIView.animate(withDuration: 0.2, delay: .zero, options: [.curveEaseOut, .allowUserInteraction]) { [weak makeTransfer] in
            makeTransfer?.tintColor = ready ? UIColor.ice : UIColor.ice24
        }
    }

}


// MARK: - Pay

extension PayController {
    
    @IBAction private func pay() {
        if payment.cardView.ready {
            let loader = LoadingScreen()
            view.addSubview(loader)
            loader.frame = view.bounds
            loader.startAnimating()
            self.loader = loader

            guard let uuid = invoice.uuid else { return }
            Vepay3DSController.paymentAndStart(uuid: uuid, form: .init(card: .init(cardNumber: payment.cardView.cardNumber, cardHolder: "holder", expires: payment.cardView.expirationDateRow, cvc: payment.cardView.cvv), size: view.bounds.size), xUser: xUser, isTest: true) { [weak self] controller in
                controller.startSSE(invoiceUUID: uuid, isTest: true)
                self?.navigationController?.pushViewController(controller, animated: true)
            } pending: {
                
            } redirectingNotNeaded: {
                
            } failure: { error in
                print(error)
            }

//            VepayInvoicePayment(invoice: invoice, card: , size: view.bounds.size, xUser: xUser, isTest: true)?.request(success: { [weak self] response in
//                guard let self = self else { return }
//                switch response.readable {
//                case .ready(let url, let method, let postParameters):
//                    start3DS(url: url, uuid: invoice.uuid!, method: method, postParameters: postParameters)
//                case .pending:
//                    print("\nPending")
//                case .redirectingNotNeaded:
//                    print("\nReadirect Not Neaded")
//                }
//                self.loader?.stopAnimationg()
//            }, error: { [weak loader] in
//                loader?.stopAnimationg()
//                print($0)
//            })
//
//        } else {
//            payment.cardView.showErrorNotReady()
        }
    }

//    private func start3DS(url: String, uuid: String, method: String, postParameters: [String: String]?) {
//        Vepay3DSController.start(url: url, method: method, postParameters: postParameters) { [weak navigationController] controller in
//            controller.startSSE(invoiceUUID: uuid, isTest: true)
//            navigationController?.pushViewController(controller, animated: true)
//        } failure: { error in
//            print("\n3DS Error\n\(error)")
//        }
//    }

}

//#Preview {
//    storyboard!.instantiateViewController(identifier: "PayController") as! PayController
//}
