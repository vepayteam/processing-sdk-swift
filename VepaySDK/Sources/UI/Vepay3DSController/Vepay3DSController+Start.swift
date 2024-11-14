//
//  Vepay3DSController+Start.swift
//  VepaySDK
//
//  Created by Bohdan Hrozian on 11/13/24.
//

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
