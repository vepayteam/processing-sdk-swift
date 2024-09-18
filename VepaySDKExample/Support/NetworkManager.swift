//
//  NetworkManager.swift
//  VepaySDK
//
//  Created by Bohdan Hrozian on 18.09.2024.
//

import VepaySDK

let networkManager = NetworkManager.shared

final class NetworkManager: VepaySessionHandler {

    static let shared = NetworkManager()
    private init() { }
    
    func request<Response>(_ request: VepayBaseRequest, success: @escaping (Response) -> Void, error: @escaping (VepayError) -> Void) where Response : Decodable {
        self.request(request) { (data, response, _error) in
            DispatchQueue.main.async {
                if let _error = _error {
                    error(VepayError(name: String(describing: _error),
                                     code: (response as? HTTPURLResponse)?.statusCode ?? .zero))
                } else if let data = data, let response = response as? HTTPURLResponse {
                    do {
                        if (200...299).contains(response.statusCode) {
                            print("Положителен", response.statusCode)
                            networkManager._print(data: data)
                            success(try JSONDecoder().decode(Response.self, from: data))
                        } else {
                            let vepayError = try JSONDecoder().decode(VepayError.self, from: data)
                            print("Ошибка", response.statusCode)
                            networkManager._print(data: data)
                            error(vepayError)
                        }
                    } catch let _error {
                        networkManager._print(data: data)
                        error(VepayError(.parseError(whenErrorOccurred: "decoding response \(String(describing: Response.self))", errorDescription: _error.localizedDescription)))
                    }
                } else {
                    error(VepayError(.noData,
                                     code: (response as? HTTPURLResponse)?.statusCode ?? .zero))
                }
            }
        }
    }

    func request(_ request: VepayBaseRequest, completion: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) {
        // URL
        var urlRequest: URLRequest
        switch request.unwrapURL() {
        case .success(let url):
            urlRequest = URLRequest(url: url)
        case .failure(let error):
            completion(nil, nil, error)
            return
        }

        // Method
        urlRequest.httpMethod = request.method.rawValue

        print("\(request.method.rawValue) \(urlRequest.url!.absoluteString)")
        switch request.bodyData() {
        case .success(let body):
            urlRequest.httpBody = body
            if body != nil {
                _print(data: body!)
            }
        case .failure(let error):
            completion(nil, nil, error)
            return
        }

        // Header
        var headers = request.headers
        headers["Content-Type"] = "application/json"
        headers["Accept-Language"] = VepayUtils.acceptLanguage()
        urlRequest.allHTTPHeaderFields = headers

        URLSession.shared.dataTask(with: urlRequest, completionHandler: completion).resume()
    }

    private func _print(data: Data) {
        print(String(data: data, encoding: .utf8) ?? "Ошибка при конвертации в utf8")
    }

}
