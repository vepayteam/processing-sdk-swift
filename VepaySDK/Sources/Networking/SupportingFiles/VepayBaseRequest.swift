//
//  VepayRequest.swift
//  Vepay
//
//  Created by Bohdan Hrozian on 25.12.2023.
//


// MARK: - Main

open class VepayBaseRequest {

    
    // MARK: - Propertys

    public let method: HTTPMethod
    public let path: String
    public let headers: [String: String]
    public let bodyEncodable: Encodable?
    public let bodyParams: [String: Any]?


    // MARK: - Init Without Body

    public init(method: HTTPMethod = .get,
                path: String,
                headers: [String: String] = [:]) {
        self.method = method
        self.path = path
        self.headers = headers
        self.bodyEncodable = nil
        self.bodyParams = nil
    }


    // MARK: - Init With Params

    public init(method: HTTPMethod = .get,
                path: String,
                headers: [String: String] = [:],
                bodyParams: [String: Any]) {
        self.method = method
        self.path = path
        self.headers = headers
        self.bodyEncodable = nil
        self.bodyParams = bodyParams
    }


    // MARK: - Init With Encodable

    public init(method: HTTPMethod = .get,
                            path: String,
                            headers: [String: String] = [:],
                            bodyEncodable: Encodable) {
        self.method = method
        self.path = path
        self.headers = headers
        self.bodyEncodable = bodyEncodable
        self.bodyParams = nil
    }


    // MARK: - URL

    public func unwrapURL() -> Result<URL, VepayError> {
        if let url = URL(string: path) {
            return .success(url)
        } else {
            return .failure(VepayError(.invalidURL(path: path)))
        }
    }


    // MARK: - Body

    public func bodyData() -> Result<Data?, VepayError> {
        do {
            let data: Data?
            if bodyParams != nil, !bodyParams!.isEmpty {
                data = try JSONSerialization.data(withJSONObject: bodyParams!, options: [])
            } else if bodyEncodable != nil {
                data = try JSONEncoder().encode(bodyEncodable!)
            } else {
                data = nil
            }
            return .success(data)
        } catch let _error {
            let error = VepayError(.parseError(
                whenErrorOccurred: "encoding body for \(path)",
                errorDescription: String(describing: _error)))
            return .failure(error)
        }
    }

    // MARK: - HTTPMethod

    public enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
        case patch = "PATCH"
    }

}


extension VepayBaseRequest {

    public func request(sessionHandler: VepaySessionHandler = VepayDefaultSessionHandler.shared,
                 completion: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) {
        sessionHandler.request(self, completion: completion)
    }

}
