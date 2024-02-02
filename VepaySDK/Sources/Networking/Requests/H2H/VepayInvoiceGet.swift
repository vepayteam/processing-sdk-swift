//
//  VepayInvoiceGet.swift
//  VepaySDK
//
//  Created by Bohdan Hrozian on 09.01.2024.
//

/// Возращает объект счёта (если счёт уже создан)
/// https://test.vepay.online/h2hapi/v1#/default/get_invoices__id_
public final class VepayInvoiceGet: VepayBaseRequest, VepayRequest {

    public typealias ResponseType = VepayInvoice
    
    /// - Parameter uuid: ID или UUID счета, ID является устаревшим
    public init(uuid: String, xUser: String, isTest: Bool = false) {
        super.init(method: .get,
                   path: VepayUtils.h2hURL(endpoint: "invoices\(uuid)", isTest: isTest),
                   headers: ["X-User": xUser])
    }

}
