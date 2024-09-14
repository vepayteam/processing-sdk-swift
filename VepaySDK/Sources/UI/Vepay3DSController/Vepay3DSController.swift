//
//  Vepay3DSController.swift
//  VepaySDK
//
//  Created by Bohdan Hrozian on 24.01.2024.
//

import WebKit
//import LDSwiftEventSource

/// Fully customizable WebController. You can use it to show WebView with 3DS
/// # Init & Start
/// Controller has many ways to start working with it.
/// All you need is to configure webView and SSE.
/// You can use Vepay3DSController.init or static methods
/// # Default Success Behavior
/// 1. Listens SSE for EventMessage.data with status
/// 2. SSE.stop and sse = nil
/// 3. Tries to parse status
/// 3. Calls threeDSFninished(status: parsedStatus ?? .inProgress)
/// # Default Error Behavior
/// If SSE connection stoped or internet connection droped, calls
/// 1. SSE.stop and sse = nil
/// 2. Calls threeDSFninished(status:  .inProgress)
/// # Default Internet Connection Handiling Behavior
/// If internet connection droped
/// 1. SSE.stop and sse = nil
/// 2. Calls threeDSFninished(status: .inProgress)
/// # Using Default Behavior
/// You can simply Vepay3DSController.init or Vepay3DSController.start, and set delegate property to listen for result
/// # Partially Custom Behavior
/// You can use delegate and overrideSSEHandler together
/// # Fully Custom SSE Behavior
/// You can use set(sse:) or startSSE(url:, delegate:)
/// # Fully Custom WebView Behavior
/// You can access controller.webView property to fully customize it
public final class Vepay3DSController: UIViewController {

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

    init() {
        super.init(nibName: nil, bundle: nil)
    }


    /// - Parameters:
    ///   - sse: sse.start()
    init(sse: EventSource? = nil, delegate: Vepay3DSControllerDelegate? = nil, overrideSSEHandler: Vepay3DSEventSourceOverrideHandler? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.sse = sse
        self.delegate = delegate
        self.overrideSSEHandler = overrideSSEHandler
    }

    /// init with 3DS Data. Init controller with configured 3DS in webView
    init(webViewURL: URL,
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
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

}


// MARK: - Life Cycle

extension Vepay3DSController {

    public override func loadView() {
        view = WKWebView()
    }

}

extension Vepay3DSController: EventHandler {

    public func onOpened() {
        overrideSSEHandler?.onOpened()
    }

    public func onClosed() {
        if overrideSSEHandler?.onClosed() ?? true {
            delegate?.threeDSFninished(status: .inProgress)
        }
    }

    public func onMessage(eventType: String, messageEvent: MessageEvent) {
        guard overrideSSEHandler?.onMessage(eventType: eventType, messageEvent: messageEvent) ?? true else { return }
        if let range = messageEvent.data.range(of: "\"status\":") {
            stopSSEAndNullify()

            let status: VepayInvoice.VepayStatus.ReadableStatus
            if let statusRaw = Int8(String(messageEvent.data[range.upperBound])) {
                status = .init(rawValue: statusRaw) ?? .inProgress
            } else {
                status = .inProgress
            }
            delegate?.threeDSFninished(status: status)
            print(status)
        }
    }

    public func onComment(comment: String) {
        overrideSSEHandler?.onComment(comment: comment)
    }

    public func onError(error: any Error) {
        guard overrideSSEHandler?.onError(error: error) ?? true else { return }
        stopSSEAndNullify()
        delegate?.threeDSFninished(status: .inProgress)
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


// MARK: - Start

extension Vepay3DSController {
    
    /// Requests VepayMake3DS
    /// # Flow:
    /// 1. VepayInvoiceCreate
    /// 2. VepayInvoicePayment
    /// 3. This method (VepayMake3DS)
    /// 4. SSE
    public static func start(url: String,
                             method: String,
                             postParameters: [String: String]?,
                             sessionHandler: any VepaySessionHandler = VepayDefaultSessionHandler.shared,
                             success: @escaping((_ data: Data, _ mimeType: String, _ characterEncodingName: String, _ baseURL: URL) -> ()),
                             failure: @escaping((VepayError) -> ())) {
        VepayMake3DS(url: url, method: method, postParameters: postParameters).request(sessionHandler: sessionHandler) { data, response, error in
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

    /// Requests VepayMake3DS and if success creates Vepay3DSController with configured webView
    /// # Flow:
    /// 1. VepayInvoiceCreate
    /// 2. VepayInvoicePayment
    /// 3. This method (VepayMake3DS)
    /// 4. SSE
    public static func start(url: String,
                             method: String,
                             postParameters: [String: String]?,
                             sessionHandler: any VepaySessionHandler = VepayDefaultSessionHandler.shared,
                             success: @escaping((Vepay3DSController) -> ()),
                             failure: @escaping((VepayError) -> ())) {
        self.start(url: url, method: method, postParameters: postParameters, sessionHandler: sessionHandler, success: { data, mimeType, characterEncodingName, baseURL in
            success(Vepay3DSController(webViewURL: baseURL, data: data, mimeType: mimeType, characterEncodingName: characterEncodingName))
        }, failure: failure)
    }

    /// Requests VepayInvoicePayment and if success creates Vepay3DSController with configured webView
    /// # Flow:
    /// 1. VepayInvoiceCreate
    /// 2. This Method (VepayInvoicePayment)
    /// 3. VepayMake3DS
    /// 4. SSE
    /// # If form is nil will call failure with (VepayError status: -1)
    /// - Parameters:
    ///   - paymentSuccessStarting: VepayInvoicePayment succes, begins creation of 3DS. You can use this method, to stop loader, and prepare to show 3DS
    public static func paymentAndStart(uuid: String,
                                       form: VepayPayment?,
                                       xUser: String,
                                       isTest: Bool = false,
                                       sessionHandler: any VepaySessionHandler = VepayDefaultSessionHandler.shared,
                                       paymentSuccessStarting: (() -> ())? = nil,
                                       success: @escaping ((Vepay3DSController) -> ()),
                                       pending: @escaping (() -> ()),
                                       redirectingNotNeaded: @escaping (() -> ()),
                                       failure: @escaping((VepayError) -> ())) {
        guard let form = form else {
            failure(VepayError(name: "Unable to obtain device IP for verification", status: -1))
            return
        }
        VepayInvoicePayment.init(uuid: uuid, form: form, xUser: xUser, isTest: isTest).request(sessionHandler: sessionHandler, success: { response in
            paymentSuccessStarting?()
            switch response.readable {
            case .ready(let url, let method, let postParameters):
                Self.start(url: url, method: method, postParameters: postParameters, sessionHandler: sessionHandler, success: success, failure: failure)
            case .pending:
                pending()
            case .redirectingNotNeaded:
                redirectingNotNeaded()
            }
        }, error: failure)
    }

    /// If invoice created but 3DS has not yet been made
    /// # Flow:
    /// 1. VepayInvoiceCreate
    /// 2. VepayInvoicePayment
    /// 3. This method (VepayInvoiceGetPayment)
    /// 4. VepayMake3DS
    /// 5. SSE
    public static func getInvoiceAndStart(uuid: String,
                                   xUser: String,
                                   sessionHandler: any VepaySessionHandler = VepayDefaultSessionHandler.shared,
                                   success: @escaping ((Data, String, String, URL) -> ()),
                                   pending: @escaping (() -> ()),
                                   redirectingNotNeaded: @escaping (() -> ()),
                                   failure: @escaping((VepayError) -> ())) {
        VepayInvoiceGetPayment(uuid: uuid, xUser: xUser).request(sessionHandler: sessionHandler, success: { invoice in
            switch invoice.readable {
            case .ready(let url, let method, let postParameters):
                Self.start(url: url, method: method, postParameters: postParameters, sessionHandler: sessionHandler, success: success, failure: failure)
            case .pending:
                pending()
            case .redirectingNotNeaded:
                redirectingNotNeaded()
            }
        }, error: failure)
    }

    /// If invoice created but 3DS has not yet been made, if success creates Vepay3DSController with configured webView
    /// # Flow:
    /// 1. VepayInvoiceCreate
    /// 2. VepayInvoicePayment
    /// 3. This method (VepayInvoiceGetPayment)
    /// 4. VepayMake3DS
    /// 5. SSE
    public static func getInvoiceAndStart(uuid: String,
                                   xUser: String,
                                   sessionHandler: any VepaySessionHandler = VepayDefaultSessionHandler.shared,
                                   success: @escaping ((Vepay3DSController) -> ()),
                                   pending: @escaping (() -> ()),
                                   redirectingNotNeaded: @escaping (() -> ()),
                                   failure: @escaping((VepayError) -> ())) {
        VepayInvoiceGetPayment(uuid: uuid, xUser: xUser).request(sessionHandler: sessionHandler, success: { invoice in
            switch invoice.readable {
            case .ready(let url, let method, let postParameters):
                Self.start(url: url, method: method, postParameters: postParameters, sessionHandler: sessionHandler, success: success, failure: failure)
            case .pending:
                pending()
            case .redirectingNotNeaded:
                redirectingNotNeaded()
            }
        }, error: failure)
    }

}
