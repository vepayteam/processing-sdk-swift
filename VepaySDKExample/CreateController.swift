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

    @IBAction private func createInvoice() {
        let statingInvoice = VepayInvoice(
            amountFractional: 50000,
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
                pay.configure(invoice: invoice)
                self.navigationController?.pushViewController(
                    pay,
                    animated: true)
            }
        }, error: {
            print("\nCreation Request Error\($0)")
        })

    }


}

