//
//  VepayError.swift
//  Vepay
//
//  Created by Bohdan Hrozian on 25.12.2023.
//



// MARK: - Main

public final class VepayError: Error, CustomStringConvertible {


    // MARK: - Properties

    public var description: String {
        var error = "Vepay Error: \n - Name: \(name)"
        if message != nil { error += "\n - Message: \(message!)" }
        error += "\n - Code: \(code)"
        if status != nil { error += "\n - Status: \(status!)" }
        return error
    }

    /// Default Error Code or HTTP Status Code
    public let name: String
    public let message: String?
    public let code: Int
    public let status: Int?

    
    // MARK: - Init
    
    public init(name: String, message: String? = nil, code: Int = .zero, status: Int? = nil) {
        self.name = name
        self.message = message
        self.code = code
        self.status = status
    }

    public convenience init(_ error: DefaultError, code: Int? = nil) {
        self.init(name: error.description, code: code ?? error.code)
    }

}


// MARK: - DefaultError

extension VepayError {
    
    public enum DefaultError: CustomStringConvertible {
        case invalidURL(path: String)
        case parseError(whenErrorOccurred: String? = nil, errorDescription: String? = nil)
        case noInternet
        case noData
        case unkownError
        case custom(message: String, code: Int)

        public var description: String {
            switch self {
            case .invalidURL(let path):
                return "Invalid URL: \(String(describing: path))"
            case .parseError(let whenErrorOccurred, let errorDescription):
                var message = "Parse Error"
                if let when = whenErrorOccurred {
                    message += "\n - Occured when \(when)"
                }
                if let description = errorDescription {
                    message += "\n - Message: \(description)"
                }
                return message
            case .noInternet:
                return "No Internet Connection"
            case .noData:
                return "No Data Occured"
            case .unkownError:
                return "Unknown Error"
            case .custom(let message, _):
                return message
            }
        }

        public var code: Int {
            switch self {
            case .invalidURL: 
                return 1
            case .parseError:
                return 2
            case .noInternet:
                return 3
            case .noData:
                return 4
            case .unkownError:
                return 5
            case .custom(_, let code):
                return code
            }
        }

    }

}


// MARK: - Decodable

extension VepayError: Decodable {

    public convenience init(from decoder: Decoder) throws {
        let container: KeyedDecodingContainer<VepayError.CodingKeys> = try decoder.container(keyedBy: VepayError.CodingKeys.self)
        let name = try container.decode(String.self, forKey: .name)
        let message = try container.decodeIfPresent(String.self, forKey: .message)
        let messageClient = try container.decodeIfPresent(String.self, forKey: .мessageclient)
        let code = try container.decodeIfPresent(Int.self, forKey: .code) ?? .zero
        let status = try container.decodeIfPresent(Int.self, forKey: .status)
        self.init(name: name, message: messageClient ?? message, code: code, status: status)
    }

    private enum CodingKeys: CodingKey {
        case name
        case message
        case code
        case status
        case мessageclient
    }

}
