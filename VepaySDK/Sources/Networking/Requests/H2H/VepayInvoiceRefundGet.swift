//
//  VepayInvoiceRefundGet.swift
//  VepaySDK
//
//  Created by Bohdan Hrozian on 26.01.2024.
//

/// Возвращает объект возврата средств
/// https://test.vepay.online/h2hapi/v1#/default/get_invoices__id__payment
public final class VepayInvoiceRefundGet: VepayBaseRequest, VepayRequest {

    public typealias ResponseType = VepayInvoice

    /// # URL Creation
    /// This method creates URL using VepayUtils.h2hURL(endpoint:, isTest). You can override h2h url using VepayUtils
    init(uuid: String, xUser: String, isTest: Bool = false) {
        super.init(method: .get,
                   path: VepayUtils.h2hURL(endpoint: "invoices\(uuid)/payment/refunds", isTest: isTest),
                   headers: ["X-User": xUser])
    }

}
