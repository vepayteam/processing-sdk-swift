//
//  PayController.swift
//  VepaySDKExample
//
//  Created by Bohdan Hrozian on 23.01.2024.
//

import WebKit
import VepaySDK


/// Example of handling VepayPaymentController UI
final class PayController: UIViewController {


    // MARK: - Views

    private(set) weak var payment: VepayPaymentController!

    @IBOutlet private weak var actionView: UIView!
    @IBOutlet private weak var makeTransfer: UIButton!

    private weak var loader: LoadingScreen?


    // MARK: - Propertys
    
    var handlePay: ((String, String, String) -> ())!

    static func fromStoryboard() -> PayController {
        UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "PayController") as! PayController
    }

}


// MARK: - Life Cycle

extension PayController {

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        payment = segue.destination as? VepayPaymentController
        payment.expirationDate = .init(month: 11, year: 25)
        payment.cardNumber = "4917610000000000"
        payment.cvv = "333"

        payment.cardViewConfiguration = .init(removeExpirtionDate: true, removeCVV: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        actionView.layer.maskedCorners = .layerMaxXMinYCorner
        setActionView(animated: false)
        payment.cardView.delegate = self
        cardView(ready: payment.cardView.ready)

//        payment.cardViewConfiguration = .init(removeExpirtionDate: true, removeCVV: true)

//        payment.cardView.hideAddCardViaNFC = true
//        payment.cardView.hideAddCardViaCamera = true
//        payment.cardView.removeCVV = false
//        payment.cardView.removeExpirtionDate = false
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
            makeTransfer?.tintColor = ready ? UIColor.ice24.withAlphaComponent(1) : UIColor.ice24
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
            handlePay(payment.cardNumber, payment.expirationDateRow, payment.cvv)
        }
    }

}

//#Preview {
//    storyboard!.instantiateViewController(identifier: "PayController") as! PayController
//}
