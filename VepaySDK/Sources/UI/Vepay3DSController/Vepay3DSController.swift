//
//  Vepay3DSController.swift
//  VepaySDK
//
//  Created by Bohdan Hrozian on 24.01.2024.
//

import WebKit

public final class Vepay3DSController: UIViewController {

    private let webView = WKWebView()

    private var sse: EventSource!
    private var uuid: String!

    public weak var delegate: Vepay3DSControllerDelegate!

}


// MARK: - Life Cycle

extension Vepay3DSController {

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(webView)
        webView.allowsBackForwardNavigationGestures = true
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        webView.frame = view.bounds
    }

}


// MARK: - 3DS

extension Vepay3DSController {
    
    /// Shows 3DS; you must starts SSE for detecting when user is done. you can user startSSE for that
    public func show3DS(url: URL, data: Data, mimeType: String, characterEncodingName: String, textEncodingName: String? = "") {
        webView.load(data, mimeType: mimeType, characterEncodingName: characterEncodingName, baseURL: url)
    }

    public func startSSE(invoiceUUID: String, isTest: Bool = false) {
        let url = VepayUtils.h2hURL(endpoint: "stream/sse?uuid=\(invoiceUUID)", isTest: isTest)
        startSSE(url: URL(string: url)!)
    }

    public func startSSE(url: URL) {
        sse = .init(url: url, delegate: self)
//        sse.listen(to: "status") You can use listen with newListened(event:)
        sse.connect()
    }

}


// MARK: - SSE

extension Vepay3DSController: EventSourceDelegate {
    
    public func new(event: EventSource.Event) {
        if let data = event.data, let range = data.range(of: "\"status\":") {
            sse?.disconnect()
            sse = nil

            let rawValue = Int8(String(data[range.upperBound])) ?? .zero
            let status = VepayInvoice.VepayStatus.ReadableStatus.init(rawValue: rawValue) ?? .inProgress
            delegate?.threeDSFninished(status: status)
        }
    }

}


// MARK: - Start

extension Vepay3DSController {

    /// VepayInvoiceCreate -> VepayInvoicePayment -> this method (VepayMake3DS) -> SSE
    public static func start(url: String,
                        method: String,
                        postParameters: [String: String]?,
                        success: @escaping((_ data: Data, _ mimeType: String, _ characterEncodingName: String, _ baseURL: URL) -> ()),
                        failure: @escaping((VepayError) -> ())) {
        VepayMake3DS(url: url, method: method, postParameters: postParameters).request { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse else { return }
            DispatchQueue.main.async {
                if let error = error {
                    failure(VepayError(name: String(describing: error),
                                       code: (response as? HTTPURLResponse)?.statusCode ?? .zero))
                } else if (httpResponse.statusCode == 200 || httpResponse.statusCode == 201), let data = data, let mimeType = httpResponse.mimeType, let url = httpResponse.url {
                    let textEncodingName = httpResponse.textEncodingName ?? ""
                    success(data, mimeType, textEncodingName, url)
                } else {
                    failure(VepayError(.noData,
                                       code: (response as? HTTPURLResponse)?.statusCode ?? .zero))
                }
            }
        }
    }

    /// VepayInvoiceCreate -> VepayInvoicePayment -> this method (VepayMake3DS) -> SSE
    public static func start(url: String,
                             method: String,
                             postParameters: [String: String]?,
                             success: @escaping((Vepay3DSController) -> ()),
                             failure: @escaping((VepayError) -> ())) {
        self.start(url: url, method: method, postParameters: postParameters, success: { data, mimeType, characterEncodingName, baseURL in
            let controller = Vepay3DSController()
            controller.show3DS(url: baseURL, data: data, mimeType: mimeType, characterEncodingName: characterEncodingName)
            success(controller)
        }, failure: failure)
    }

    /// this method (VepayInvoicePaymentGet) ->  start -> SSE
    /// - Parameters:
    ///   - failure: if invoice status isn't ready; will throw VepayError.unkownError
    public static func getAndStart(uuid: String, xUser: String, success: @escaping ((Data, String, String, URL) -> ()), failure: @escaping((VepayError) -> ())) {
        VepayInvoiceGetPayment(uuid: uuid, xUser: xUser).request(success: { invoice in
            switch invoice.readable {
            case .ready(let url, let method, let postParameters):
                Self.start(url: url, method: method, postParameters: postParameters, success: success, failure: failure)
            default:
                failure(.init(.unkownError))
            }
        }, error: failure)
    }

    /// this method (VepayInvoicePaymentGet) ->  start -> SSE
    /// - Parameters:
    ///   - failure: if invoice status isn't ready; will throw VepayError.unkownError
    public static func getAndStart(uuid: String, xUser: String, success: @escaping ((Vepay3DSController) -> ()), failure: @escaping((VepayError) -> ())) {
        VepayInvoiceGetPayment(uuid: uuid, xUser: xUser).request(success: { invoice in
            switch invoice.readable {
            case .ready(let url, let method, let postParameters):
                Self.start(url: url, method: method, postParameters: postParameters, success: success, failure: failure)
            default:
                failure(.init(.unkownError))
            }
        }, error: failure)
    }

}


// MARK: - Vepay3DSControllerDelegate

public protocol Vepay3DSControllerDelegate: NSObject {
    
    func threeDSFninished(status: VepayInvoice.VepayStatus.ReadableStatus)

}
