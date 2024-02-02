//
//  Vepay3DS.swift
//  VepaySDK
//
//  Created by Bohdan Hrozian on 23.01.2024.
//

import WebKit

/// Выполняет 3DS
/// Example: https://some-access-control-server.com/3ds?payId=123
public final class VepayMake3DS: VepayBaseRequest, VepayRequest {

    public typealias ResponseType = VepayInvoice

    public init(url: String, method: String, postParameters: [String: String]?) {
        super.init(method: .init(rawValue: method) ?? .get, path: url, bodyParams: postParameters ?? [:])
    }

}
