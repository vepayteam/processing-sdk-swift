//
//  VepayInvoicePayment.swift
//  VepaySDK
//
//  Created by Bohdan Hrozian on 09.01.2024.
//

import CoreGraphics.CGBase

/// Производит оплату счёта
/// https://test.vepay.online/h2hapi/v1#/default/put_invoices__id__payment
public final class VepayInvoicePayment: VepayBaseRequest, VepayRequest {

    public typealias ResponseType = VepayPaymentResponse

    /// # URL Creation
    /// This method creates URL using VepayUtils.h2hURL(endpoint:, isTest). You can override h2h url using VepayUtils
    public init(uuid: String, form: VepayPayment, xUser: String, isTest: Bool = false) {
        super.init(method: .put,
                   path: VepayUtils.h2hURL(endpoint: "invoices/\(uuid)/payment", isTest: isTest),
                   headers: ["X-User": xUser],
                   bodyEncodable: form)
    }

    /// nil if invoice hasn't UUD
    /// # URL Creation
    /// This method creates URL using VepayUtils.h2hURL(endpoint:, isTest). You can override h2h url using VepayUtils
    public convenience init?(invoice: VepayInvoice, form: VepayPayment, xUser: String, isTest: Bool = false) {
        guard invoice.uuid != nil || invoice.id != nil else { return nil }
        let uuid = invoice.uuid ?? "\(invoice.id!)"
        self.init(uuid: uuid, form: form, xUser: xUser, isTest: isTest)
    }

    /// nil if invoice hasn't UUD or can't find ip address
    /// # URL Creation
    /// This method creates URL using VepayUtils.h2hURL(endpoint:, isTest). You can override h2h url using VepayUtils
    public convenience init?(invoice: VepayInvoice, card: VepayPaymentCard, specificIPVersion: VepayUtils.IPVersion? = nil, size: CGSize, xUser: String, isTest: Bool = false) {
        guard let form = VepayPayment(card: card, size: size, specificIPVersion: specificIPVersion) else { return nil }
        self.init(invoice: invoice, form: form, xUser: xUser, isTest: isTest)
    }
}
