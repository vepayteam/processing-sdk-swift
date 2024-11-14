//
//  Vepay3DSController.swift
//  VepaySDK
//
//  Created by Bohdan Hrozian on 24.01.2024.
//

import WebKit


/// Fully customizable UIViewController. it's view == WKWebView. You can use it to show WebView with 3DS
/// # Init & Start
/// Controller has many ways to start working with it.
/// All you need is to configure webView and SSE.
/// You can use Vepay3DSController.init or static methods
/// # Default Success Behavior
/// 1. Listens SSE for EventMessage.data with status
/// 2. SSE.stop and sse = nil
/// 3. Tries to parse status
/// 4. Calls delegate.sseUpdated
/// If returns true, sse will close, if false sse continue accept events
/// # Default Error Behavior
/// If SSE connection stoped or internet connection droped, calls
/// 1. SSE.stop and sse = nil
/// 2. Calls delegate.sseClosed()
/// # Using Default Behavior
/// You can simply Vepay3DSController.init or Vepay3DSController.start, and set delegate property to listen for result
/// # Partially Custom Behavior
/// You can use delegate and overrideSSEHandler together
/// # Fully Custom SSE Behavior
/// You can use set(sse:) or startSSE(url:, delegate:)
/// # Fully Custom WebView Behavior
/// You can access controller.webView property to fully customize it
public final class Vepay3DSController: UIViewController {


    // MARK: - Propertys

    public var webView: WKWebView { view as! WKWebView }

    /// You can set SSE using set(sse:) or startSSE(url:, delegate:)
    public private(set) var sse: EventSource?
    /// If you are using default behavior of this controller, you need this property
    /// # Default Behavior
    /// You can simply set this property
    /// # Partially Custom Behavior
    /// You can set this property and override specific aspect of behavior by using overrideSSEHandler
    /// # Fully Custom Behavior
    /// You can use set(sse:) or startSSE(url:, delegate:), and leave leave this property to nil
    public weak var delegate: Vepay3DSControllerDelegate?
    /// Allows to customize specific part of behavior. For more information, you can read in Vepay3DSController description
    public weak var overrideSSEHandler: Vepay3DSEventSourceOverrideHandler?


    // MARK: - Init

    public init() {
        super.init(nibName: nil, bundle: nil)
    }

    /// - Parameters:
    ///   - sse: sse.start()
    public init(sse: EventSource? = nil, delegate: Vepay3DSControllerDelegate? = nil, overrideSSEHandler: Vepay3DSEventSourceOverrideHandler? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.sse = sse
        self.delegate = delegate
        self.overrideSSEHandler = overrideSSEHandler
    }

    /// init with 3DS Data. Init controller with configured 3DS in webView
    public init(webViewURL: URL,
         data: Data? = nil,
         mimeType: String? = nil,
         characterEncodingName: String? = nil,
         textEncodingName: String? = "") {
        super.init(nibName: nil, bundle: nil)
        if let data = data, let mimeType = mimeType, let characterEncodingName = characterEncodingName {
            show3DS(url: webViewURL, data: data, mimeType: mimeType, characterEncodingName: characterEncodingName, textEncodingName: textEncodingName)
        } else {
            show3DS(url: webViewURL)
        }
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

}


// MARK: - Life Cycle

extension Vepay3DSController {

    public override func loadView() {
        view = WKWebView()
    }

}


// MARK: - SSE Delegate

extension Vepay3DSController: EventHandler {

    public func onOpened() {
        overrideSSEHandler?.onOpened()
    }

    public func onClosed() {
        if overrideSSEHandler?.onClosed() ?? true {
            delegate?.sseClosed()
        }
    }

    public func onMessage(eventType: String, messageEvent: MessageEvent) {
        guard overrideSSEHandler?.onMessage(eventType: eventType, messageEvent: messageEvent) ?? messageEvent.data.contains("status") else { return }
        let data = messageEvent.data.replacingOccurrences(of: "\"", with: "", options: .regularExpression)
        if let statusUpperBound = data.range(of: "status:")?.upperBound {
            var int: Int8? = nil
            var string: String? = nil
            if let statusInt = Int8(String(data[statusUpperBound])) {
                int = statusInt
            } else {
                let endIndex = data.range(of: ",", range: .init(uncheckedBounds: (lower: statusUpperBound, upper: data.endIndex)))?.lowerBound ?? data.endIndex
                string = data[statusUpperBound...endIndex].replacingOccurrences(of: "[^A-Z]", with: "", options: .regularExpression)
            }

            if delegate?.sseUpdated(int: int, string: string) ?? true {
                stopSSEAndNullify()
            }
        }
    }

    public func onComment(comment: String) {
        overrideSSEHandler?.onComment(comment: comment)
    }

    public func onError(error: any Error) {
        guard overrideSSEHandler?.onError(error: error) ?? true else { return }
        stopSSEAndNullify()
        delegate?.sseClosed()
    }

    func stopSSEAndNullify() {
        sse?.stop()
        sse = nil
    }

}


// MARK: - Configure SSE & WebView

extension Vepay3DSController {

    /// You can use this method, to create sse on app side, and store it in this controller (sse.start())
    public func set(sse: EventSource) {
        self.sse = sse
        sse.start()
    }
    
    /// Create and start SSE
    /// - Parameters:
    ///   - url: url for SSE
    ///   - delegate: if nil, Vepay3DSController will handle events
    public func startSSE(url: URL, handler: EventHandler? = nil) {
        var config = EventSource.Config(handler: handler ?? self, url: url)
        config.connectionErrorHandler = { error in
            return .shutdown
        }
        set(sse: EventSource(config: config))
    }

    /// Create and start SSE with h2hURL
    public func startSSE(invoiceUUID: String, handler: EventHandler? = nil, isTest: Bool = false) {
        let url = VepayUtils.h2hURL(endpoint: "stream/sse?uuid=\(invoiceUUID)", isTest: isTest)
        startSSE(url: URL(string: url)!, handler: handler)
    }

    public func show3DS(url: URL, data: Data, mimeType: String, characterEncodingName: String, textEncodingName: String? = "") {
        webView.load(data, mimeType: mimeType, characterEncodingName: characterEncodingName, baseURL: url)
    }

    public func show3DS(url: URL) {
        webView.load(URLRequest(url: url))
    }

}
