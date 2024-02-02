//
//  VepayRequestType.swift
//  Vepay
//
//  Created by Bohdan Hrozian on 25.12.2023.
//


// MARK: - VepayRequestHandler

public protocol VepayRequest {
    associatedtype ResponseType: Decodable
}

public extension VepayRequest where Self: VepayBaseRequest  {

    /// Throws error if problem with creating URL or body encoding
    func request(sessionHandler: VepaySessionHandler = VepayDefaultSessionHandler.shared,
                 success: @escaping (ResponseType) -> Void,
                 error: @escaping (VepayError) -> Void) {
        sessionHandler.request(self, success: success, error: error)
    }

}
