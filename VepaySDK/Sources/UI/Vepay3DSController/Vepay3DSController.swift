//
//  Vepay3DSController.swift
//  VepaySDK
//
//  Created by Bohdan Hrozian on 24.01.2024.
//

import WebKit


/// ViewController where view is WKWebView (to present 3DS).
/// Has sseHandler, to use it, set sseHandler.delegate & sseHandler.set
public final class Vepay3DSController: UIViewController {


    // MARK: - Propertys

    public var webView: WKWebView { view as! WKWebView }

    /// You can use this property to handle SSE connection by setting delegate. If you want to override sseHandler, you can create sub class, and store it here
    public var sseHandler = VepaySSEHandler()

    // MARK: - Init

    public init() {
        super.init(nibName: nil, bundle: nil)
    }

    public init(sseDelegate: VepaySSEHandlerDelegate? = nil) {
        super.init(nibName: nil, bundle: nil)
        sseHandler.delegate = sseDelegate
    }

    /// init with 3DS Data. Init controller with configured 3DS in webView
    public init(webViewURL: URL,
                data: Data? = nil,
                mimeType: String? = nil,
                characterEncodingName: String? = nil,
                textEncodingName: String? = "",
                sseDelegate: VepaySSEHandlerDelegate? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.sseHandler.delegate = sseDelegate
        if let data = data, let mimeType = mimeType, let characterEncodingName = characterEncodingName {
            show3DS(url: webViewURL, data: data, mimeType: mimeType, characterEncodingName: characterEncodingName, textEncodingName: textEncodingName)
        } else {
            show3DS(url: webViewURL)
        }
    }

    public override func loadView() {
        view = WKWebView()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

}


// MARK: - Configure SSE & WebView

extension Vepay3DSController {

    /// Create and start SSE with h2hURL. And stores it in sseHandler
    public func startSSE(invoiceUUID: String, isTest: Bool = false) {
        let url = VepayUtils.h2hURL(endpoint: "stream/sse?uuid=\(invoiceUUID)", isTest: isTest)
        sseHandler.set(sse: URL(string: url)!)
    }

    public func show3DS(url: URL, data: Data, mimeType: String, characterEncodingName: String, textEncodingName: String? = "") {
        webView.load(data, mimeType: mimeType, characterEncodingName: characterEncodingName, baseURL: url)
    }

    public func show3DS(url: URL) {
        webView.load(URLRequest(url: url))
    }

}
