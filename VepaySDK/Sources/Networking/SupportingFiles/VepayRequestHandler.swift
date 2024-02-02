//
//  VepayRequestHandler.swift
//  
//
//  Created by Bohdan Hrozian on 25.12.2023.
//

import WebKit


// MARK: - VepayNetworkHandler

public protocol VepaySessionHandler {

    func request<Response: Decodable>(_ request: VepayBaseRequest,
                      success: @escaping (Response) -> Void,
                      error: @escaping (VepayError) -> Void)

    func request(_ request: VepayBaseRequest, completion: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void)

}


// MARK: - VepayDefaultNetworkHandler

/// Default request handler, only handles 1 request at the time
public final class VepayDefaultSessionHandler: NSObject, VepaySessionHandler {

    // MARK: - Singleton

    public static let shared = VepayDefaultSessionHandler()
    private override init() { }

}


// MARK: - Request

extension VepayDefaultSessionHandler {


    // MARK: - Request & Decode
    /// Throws error if problem with creating URL or body encoding
    public func request<Response: Decodable>(_ request: VepayBaseRequest,
                      success: @escaping (Response) -> Void,
                      error: @escaping (VepayError) -> Void) {
//        // Request
        let urlRequest: URLRequest
        switch createRequest(request) {
        case .success(let request):
            urlRequest = request
        case .failure(let _error):
            error(_error)
            return
        }
        
        URLSession.shared.dataTask(with: urlRequest) { (data, response, _error) in
            DispatchQueue.main.async {
                if let _error = _error {
                    error(VepayError(name: String(describing: _error),
                                     code: (response as? HTTPURLResponse)?.statusCode ?? .zero))
                } else if let data = data, let response = response as? HTTPURLResponse {
                    do {
                        if (200...299).contains(response.statusCode) {
                            success(try JSONDecoder().decode(Response.self, from: data))
                        } else {
                            let vepayError = try JSONDecoder().decode(VepayError.self, from: data)
                            error(vepayError)
                        }
                    } catch let _error {
                        error(VepayError(.parseError(whenErrorOccurred: "decoding response \(String(describing: Response.self))", errorDescription: _error.localizedDescription), code: response.statusCode))
                    }
                } else {
                    error(VepayError(.noData,
                                     code: (response as? HTTPURLResponse)?.statusCode))
                }
            }
        }.resume()
    }
    
    
    // MARK: Request Only

    public func request(_ request: VepayBaseRequest, completion: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) {
        let urlRequest: URLRequest
        switch createRequest(request) {
        case .success(let request):
            urlRequest = request
        case .failure(let error):
            completion(nil, nil, error)
            return
        }
        URLSession.shared.dataTask(with: urlRequest, completionHandler: completion).resume()
    }
    

    private func createRequest(_ request: VepayBaseRequest) -> Result<URLRequest, VepayError> {
        // URL
        var urlRequest: URLRequest
        switch request.unwrapURL() {
        case .success(let url):
            urlRequest = URLRequest(url: url)
        case .failure(let error):
            return .failure(error)
        }

        // Method
        urlRequest.httpMethod = request.method.rawValue

        switch request.bodyData() {
        case .success(let body):
            urlRequest.httpBody = body
        case .failure(let error):
            return .failure(error)
        }

        // Header
        var headers = request.headers
        headers["Content-Type"] = "application/json"
        headers["Accept-Language"] = VepayUtils.acceptLanguage()
        urlRequest.allHTTPHeaderFields = headers

        return .success(urlRequest)
    }

}
