//
//  VepayInvoiceGetPayment.swift
//  VepaySDK
//
//  Created by Bohdan Hrozian on 09.01.2024.
//

/// Возращает оплату счёта (если счёт уже создан и его нужно оплатить)
/// https://test.vepay.online/h2hapi/v1#/default/get_invoices__id__payment
public final class VepayInvoiceGetPayment: VepayBaseRequest, VepayRequest {

    public typealias ResponseType = VepayPaymentResponse
    
    /// - Parameter uuid: ID или UUID счета, ID является устаревшим
    init(uuid: String, xUser: String, isTest: Bool = false) {
        super.init(method: .get, 
                   path: VepayUtils.h2hURL(endpoint: "invoices\(uuid)/payment", isTest: isTest),
                   headers: ["X-User": xUser])
    }

}

