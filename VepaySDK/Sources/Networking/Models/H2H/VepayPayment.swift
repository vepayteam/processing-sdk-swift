//
//  VepayPayment.swift
//  VepaySDK
//
//  Created by Bohdan Hrozian on 08.01.2024.
//

import UIKit.UIView

// MARK: - Payment

/// https://test.vepay.online/h2hapi/v1#/default/put_invoices__id__payment
public struct VepayPayment: Codable {


    // MARK: - Propertys

    /// IP Клиента
    /// # Example: 108.177.16.21
    public let ip: String

    /// Данные карты
    public let card: VepayPaymentCard

    /// HTTP-заголовки
    public let headerMap: VepayHeaderMap

    /// Данные браузера пользователя
    public let browserData: VepayBrowserData


    // MARK: - Init

    /// - Parameters:
    ///   - ip: You can occured IP using VepayUtils.ip()
    public init(ip: String, card: VepayPaymentCard, headerMap: VepayHeaderMap = .init(), browserData: VepayBrowserData) {
        self.ip = ip
        self.card = card
        self.headerMap = headerMap
        self.browserData = browserData
    }
    
    /// Occure ip from VepayUtils.ip(), default headerMap. nil if can't get ip
    /// - Parameters:
    ///   - size: of WebView where 3DS will be presented
    public init?(card: VepayPaymentCard, size: CGSize, specificIPVersion: VepayUtils.IPVersion? = nil) {
        if let ip = VepayUtils.ip(specificIPVersion: specificIPVersion) {
            self.ip = ip
            self.card = card
            self.headerMap = .init()
            self.browserData = .init(sizeOfPresentingView: size)
        } else { return nil }
    }

}


// MARK: - Header Map

extension VepayPayment {
    
    public struct VepayHeaderMap: Codable {

        /// HTTP-заголовок User-Agent
        /// # Max Length: 255
        /// # Example: "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.103 Safari/537.36"
        public let userAgent: String

        /// HTTP-заголовок Accept
        /// # Max Length: 255
        /// # Example: text/html
        public let accept: String?

        /// HTTP-заголовок Accept-Language
        /// # Max Length: 255
        /// # Example: ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7
        public let acceptLanguage: String?
        
        /// - Parameters:
        ///   - userAgent: = VepayUtils.userAgent()
        ///   - accept: = text/html
        ///   - acceptLanguage: = VepayUtils.acceptLanguage()
        public init(userAgent: String = VepayUtils.userAgent(), accept: String = "application/json" /*"text/html"*/, acceptLanguage: String? = VepayUtils.acceptLanguage()) {
            self.userAgent = userAgent
            self.accept = accept
            self.acceptLanguage = acceptLanguage
        }

        // userAgent = VepayUtils.userAgent(); accept = text/html; acceptLanguage = VepayUtils.acceptLanguage()
        /// - Parameters:
        ///   - userAgent: = VepayUtils.userAgent()
        ///   - accept: = text/html
        ///   - acceptLanguage: = VepayUtils.acceptLanguage()
        public init() {
            self.userAgent = VepayUtils.userAgent()
//            self.accept = "text/html"
            self.accept = "application/json"
            self.acceptLanguage = VepayUtils.acceptLanguage()
        }

    }

}


// MARK: - Browser Data

extension VepayPayment {
    
    public struct VepayBrowserData: Codable {
        
        /// Высота экрана. JavaScript: window.screen.height
        /// # Example: 800
        public let screenHeight: Int

        /// Ширина экрана. JavaScript: window.screen.width
        /// # Example: 1200
        public let screenWidth: Int

        /// Высота окна. JavaScript: window.outerHeight
        /// # Example: 800
        public let windowHeight: Int

        /// Ширина окна. JavaScript: window.outerWidth
        /// # Example: 1200
        public let windowWidth: Int

        /// Разница между временной зоной браузера и UTC в минутах. JavaScript: (new Date()).getTimezoneOffset()
        /// # Example: -180
        public let timezoneOffset: Int

        /// Язык браузера (ISO). JavaScript: window.navigator.language || window.navigator.userLanguage
        /// # Max Length: 5
        /// # Example ru-RU
        public let language: String

        /// Глубина цвета. JavaScript: window.screen.colorDepth
        /// # Example: 24
        public let colorDepth: Int

        /// Java включен. JavaScript: window.navigator.javaEnabled()
        /// # Example: false
        public let javaEnabled: Bool

        // MARK: - Init

        public init(screenHeight: Int, screenWidth: Int, windowHeight: Int, windowWidth: Int, timezoneOffset: Int, language: String, colorDepth: Int, javaEnabled: Bool) {
            self.screenHeight = screenHeight
            self.screenWidth = screenWidth
            self.windowHeight = windowHeight
            self.windowWidth = windowWidth
            self.timezoneOffset = timezoneOffset
            self.language = language
            self.colorDepth = colorDepth
            self.javaEnabled = javaEnabled
        }

        /// - Parameter view: Must be added to the window, because from it will be calculated screen size
        public init(sizeOfPresentingView size: CGSize) {
            self.screenHeight = Int(size.height)
            self.windowHeight = Int(size.height)
            self.screenWidth = Int(size.width)
            self.windowWidth = Int(size.width)

            timezoneOffset = Self.calculateTimeZoneOffsetInMinutes()

            language = VepayUtils.activeLanguage()

            colorDepth = 16

            javaEnabled = false
        }

        public static func calculateTimeZoneOffsetInMinutes() -> Int {
            TimeZone.current.secondsFromGMT() / 60
        }

    }
    
}


// MARK: - Response

public struct VepayPaymentResponse: Decodable {

    public let card: VepayPaymentCard?
    /// Данные для перенаправления пользователя на страницу ACS (проверка 3DS), если надо
    public let acsRedirect: Redirect?

    public var readable: Redirect.Readable { .init(acsRedirect) }

}


// MARK: - Redirect

extension VepayPaymentResponse {
    
    public struct Redirect: Codable {

        /// Статус перенаправления
        /// # Example: OK
        /// * "OK" - Готово
        /// * "PENDING" - Ожидание. Требуется сделать повторный запрос позже.
        public let status: String

        /// URL страницы проверки 3DS. null, если статус PENDING.
        /// # Example: https://some-access-control-server.com/3ds?payId=123
        public let url: String?

        /// HTTP-метод для перенаправления браузера пользователя на страницу проверки 3DS. Если POST, потребуется добавить форму с указанным адресом и параметрами на страницу оплаты в браузере клиента и отправить с помощью JavaScript. null, если статус PENDING.
        /// /// # Example: POST
        public let method: String?

        /// Параметры формы для перенаправления методом POST. nill, если метод GET или статус PENDING. Состав параметров не фиксированный (может меняться), определяется банком.
        /// # Example:
        ///  * "pa_req": "K8QufpC0UQXOoYcNlfT857Tvu15Wli12WXyvCyTX8AKY2QyMUCk",
        /// * "md": "YcNlfT857Tvu15Wli12WXyvCyTX8AKY2QyMUCkGMifQ==",
        /// * "term_url": "https://api.vepay.online/pay/orderdone/12345"
        public let postParameters: [String: String]?

        public enum Readable {
            /// "OK" - Готово
            /// URL Example: https://some-access-control-server.com/3ds?payId=123
            /// Method: POST || GET
            /// PostParameters Example:
            /// * "pa_req": "K8QufpC0UQXOoYcNlfT857Tvu15Wli12WXyvCyTX8AKY2QyMUCk",
            /// * "md": "YcNlfT857Tvu15Wli12WXyvCyTX8AKY2QyMUCkGMifQ==",
            /// * "term_url": "https://api.vepay.online/pay/orderdone/12345"
            case ready(url: String, method: String, postParameters: [String: String]?)

            /// "PENDING" - Ожидание. Требуется сделать повторный запрос позже.
            case pending

            case redirectingNotNeaded

            public init(_ model: Redirect?) {
                if model?.status == "OK", let url = model?.url, let method = model?.method {
                    self = .ready(url: url, method: method, postParameters: model?.postParameters)
                } else if model?.status == "PENDING" {
                    self = .pending
                } else {
                    self = .redirectingNotNeaded
                }
            }
        }

    }
    
}
