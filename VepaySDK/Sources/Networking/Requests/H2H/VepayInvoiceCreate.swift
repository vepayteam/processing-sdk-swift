//
//  VepayInvoiceCreate.swift
//  VepaySDK
//
//  Created by Bohdan Hrozian on 09.01.2024.
//

/// Производит создание счёта
/// https://test.vepay.online/h2hapi/v1#/default/post_invoices
public final class VepayInvoiceCreate: VepayBaseRequest, VepayRequest {

    public typealias ResponseType = VepayInvoice

    public init(invoice: VepayInvoice, xUser: String, isTest: Bool = false) {
        super.init(method: .post,
                   path: VepayUtils.h2hURL(endpoint: "invoices", isTest: isTest),
                   headers: ["X-User": xUser],
                   bodyEncodable: invoice)
    }

}
