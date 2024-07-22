//
//  ViewController.swift
//  VepaySDKExample
//
//  Created by Bohdan Hrozian on 28.12.2023.
//

import UIKit
import VepaySDK


let xUser = ""

final class CreateController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let pay = storyboard!.instantiateViewController(identifier: "PayController") as! PayController
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            pay.payment.set(cards: [.init(id: 0,
                                          number: "4917000000000000",
                                          expire: "1130",
                                          holder: "Cezary Stypulkowski",
                                          paymentSystem: "VISA",
                                          bank: VepayBank(
                                            name: "PEKAO",
                                            icon: UIImage(named: "PekaoIconExample", in: .vepaySDK, compatibleWith: nil)!,
                                            logo: UIImage(named: "PekaoLogoExample", in: .vepaySDK, compatibleWith: nil)!,
                                            color: .red)),])
        }
        self.navigationController?.pushViewController(
            pay,
            animated: true)
    }

    @IBAction private func createInvoice() {
        let statingInvoice = VepayInvoice(
            amountFractional: 30000,
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

        VepayInvoiceCreate(invoice: statingInvoice, xUser: xUser, isTest: true).request(success: { [weak self] invoice in
            if let self = self {
                let pay = storyboard!.instantiateViewController(identifier: "PayController") as! PayController
//                pay.overrideSavedCards = true
                pay.configure(invoice: invoice)
                self.navigationController?.pushViewController(
                    pay,
                    animated: true)
            }
        }, error: {
            print("\nCreation Request Error\($0)")
        })
    }


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

