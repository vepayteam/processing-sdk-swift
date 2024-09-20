//
//  VepayInvoiceRefund.swift
//  VepaySDK
//
//  Created by Bohdan Hrozian on 09.01.2024.
//

/// Производит возврат средств
/// https://test.vepay.online/h2hapi/v1#/default/post_invoices__id__payment_refunds
public final class VepayInvoiceRefund: VepayBaseRequest, VepayRequest {

    public typealias ResponseType = VepayRefund
    
    /// - Parameters:
    ///   - uuid: ID или UUID счета, ID является устаревшим
    ///   - amount: В копейках
    /// # URL Creation
    /// This method creates URL using VepayUtils.h2hURL(endpoint:, isTest). You can override h2h url using VepayUtils
    init(uuid: String, amount: Int, xUser: String, isTest: Bool = false) {
        super.init(method: .post,
                   path: VepayUtils.h2hURL(endpoint: "invoices\(uuid)/payment/refunds", isTest: isTest),
                   headers: ["X-User": xUser],
                   bodyParams: ["amountFractional": amount])
    }

}
