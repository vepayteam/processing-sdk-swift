//
//  VepayInvoiceRefunds.swift
//  VepaySDK
//
//  Created by Bohdan Hrozian on 09.01.2024.
//

/// Производит отмену платежа
/// https://test.vepay.online/h2hapi/v1#/default/put_invoices__id__payment_reversed
public final class VepayInvoiceCancel: VepayBaseRequest, VepayRequest {

    public typealias ResponseType = VepayInvoice

    /// # URL Creation
    /// This method creates URL using VepayUtils.h2hURL(endpoint:, isTest). You can override h2h url using VepayUtils
    init(uuid: String, xUser: String, isTest: Bool = false) {
        super.init(method: .put,
                   path: VepayUtils.h2hURL(endpoint: "invoices\(uuid)/payment/reversed", isTest: isTest),
                   headers: ["X-User": xUser])
    }

}
