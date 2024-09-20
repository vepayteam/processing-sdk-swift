//
//  AppearFlowController.swift
//  VepaySDK
//
//  Created by Bohdan Hrozian on 18.09.2024.
//

import UIKit
import VepaySDK

final class AppearFlowController: UIViewController {


    // MARK: - Proeprtys

    /// https://api.appeer.ru
    @IBOutlet private weak var urlBase: UITextField!
    @IBOutlet private weak var transactionID: UITextField!

    @IBOutlet private weak var xUser: UITextField!
    @IBOutlet private weak var accessToken: UITextField!

    @IBOutlet private weak var paste: UIButton!
    @IBOutlet private weak var start: UIButton!

    let defaultURL = "https://api.appeer.ru"

    var invoice: Invoice!
    /// 7eb583f2-7a8c-4be3-9838-8afff0410c16
    /// eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJ3VHVLQWFMUVBLOENFV0JheEpINGVoZVVHR0tuRlZiYyIsImV4cCI6MTcyNjY2ODAwNCwibmJmIjoxNzI2NjY3OTQ0LCJzdWIiOiJhYjk0MGI4ZC0zYTY0LTRjNDItYjVkOS1iNzRkYmYwOGYxMTMiLCJyb2xlcyI6WyJcdTA0MWFcdTA0M2JcdTA0MzhcdTA0MzVcdTA0M2RcdTA0NDIiXSwicGhvbmUiOiIrNzk3ODU4OTQ1NzkifQ.BaQoNJhjm_VV79fgoHI6ecehDzEW8QTpUCmKh6k18cs","refreshToken":"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJZbzVzMWpTcTdMSmJvVUxEcWNYRjJlRDZOdVhuWkNCaiIsImV4cCI6MTcyNjY2ODg0NCwibmJmIjoxNzI2NjY3OTQ0LCJzdWIiOiJhYjk0MGI4ZC0zYTY0LTRjNDItYjVkOS1iNzRkYmYwOGYxMTMiLCJyb2xlcyI6WyJcdTA0MWFcdTA0M2JcdTA0MzhcdTA0MzVcdTA0M2RcdTA0NDIiXSwicGhvbmUiOiIrNzk3ODU4OTQ1NzkifQ.MHrAa7XluLXRp5i6FOiqaHbhfYqdkl6cth041KZ9lLM
}


// MARK: - Start

extension AppearFlowController {

    private func startPay() {
        guard !urlBase.text!.isEmpty, !transactionID.text!.isEmpty, !xUser.text!.isEmpty, !accessToken.text!.isEmpty else {
            return
        }
        UserDefaults.standard.set(xUser.text, forKey: "XUserAppear")
        UserDefaults.standard.set(accessToken.text, forKey: "AcessTokenAppear")
        UserDefaults.standard.set(urlBase.text, forKey: "UrlBase")
        let pay = PayController.fromStoryboard()
        pay.handlePay = handlePay
        self.navigationController?.pushViewController(pay, animated: true)
    }

    // MARK: - Handle Pay
    
    private func handlePay(cardNumber: String, expirationDate: String, cvv: String) {
        let urlBase = urlBase.text!
        let xUser = xUser.text!
        let accessToken = accessToken.text!
        let body = AppearInvoiceCreateBody(transactionId: transactionID.text!, senderCardPan: cardNumber, senderCardExpMonth: String(expirationDate.prefix(2)), senderCardExpYear: String(expirationDate.suffix(2)), senderCardCvv: cvv)

        AppearInvoiceCreate(urlBase: urlBase, xUser: xUser, accessToken: accessToken, body: body).request(sessionHandler: networkManager) { [self] invoice in
            self.invoice = invoice
        } error: { [self] error in
            presentAlert(title: "Appear Invoice Error", body: error.description, showGoToMainScreen: true)
        }

    }

    private func requestTransfer() {
        "\(urlBase.text!)/"
        networkManager.request(request: .init(urlBase: .api, endpoint: .withUserUUID("transactions/\(uuid)"), addAccessToken: true), completion: completion)
    }

    private func start3DS() {
        let controller = Vepay3DSController()
        let url = URL(string: "\(self.urlBase.text!)/sse/\(invoice.transactionId!)")!
        controller.startSSE(url: url)
        
        controller.show3DS(url: URL(string: invoice.redirectUrl!)!)
        controller.delegate = self
        navigationController?.pushViewController(controller, animated: true)
    }

}


// MARK: - SSE

extension AppearFlowController: Vepay3DSControllerDelegate {

    func sseUpdated(status: VepaySDK.TransactionStatus) -> Bool {
        let title: String
        var willStop = true
        switch status {
        case .failed:
            title = "Failed"
        case .initiated:
            title = "Initiated"
            willStop = false
        case .processing:
            title = "In Progress"
            willStop = false
        case .done:
            title = "Done"
        case .pending:
            title = "Pending"
            willStop = false
        case .paid:
            title = "Paid"
            willStop = false
        case .invoiceFailed:
            title = "Invoice Failed"
        case .unknown(let int, let string):
            title = "Unknown Status: \(int != nil ? "\(int!)" : string ?? "Empty")"
        }

        presentAlert(title: "\(title)", body: "SSE Stoped \(willStop)", showGoToMainScreen: willStop)
        return willStop
    }
    
    func sseClosed() {
        presentAlert(title: "SSE Closed", body: nil, showGoToMainScreen: true)
    }

    private func presentAlert(title: String, body: String?, showGoToMainScreen: Bool) {
        DispatchQueue.main.async { [weak self] in
            let alert = UIAlertController(title: title, message: body, preferredStyle: .actionSheet)
            alert.addAction(.init(title: "Cancel", style: .cancel))
            if showGoToMainScreen {
                alert.addAction(.init(title: "Go To Main Screen", style: .default, handler: { [weak self] _ in
                    self?.navigationController?.popToRootViewController(animated: true)
                }))
            }
            self?.navigationController?.present(alert, animated: true)
        }
    }

}


// MARK: - Support

extension AppearFlowController {

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        urlBase.text = UserDefaults.standard.string(forKey: "UrlBase") ?? defaultURL
        xUser.text = UserDefaults.standard.string(forKey: "XUserAppear")
        accessToken.text = UserDefaults.standard.string(forKey: "AcessTokenAppear")
        urlBase.font = .subHeading
        transactionID.font = .subHeading
        paste.titleLabel?.font = .bodyLarge
        start.titleLabel?.font = .subHeading
    }


    // MARK: - Actions

    @IBAction private func tapped(button: UIButton) {
        if button == start {
            startPay()
        } else {
            pasteFromClipboard()
        }
    }
    
    /*
     https://api.appeer.ru/sse/qwenjkfl123401-1432fqw-fqwef
     */
    private func pasteFromClipboard() {
        guard let string = UIPasteboard.general.string else { return }
        if let separatorRange = string.ranges(of: "/").last {
            // Whole URL
            var urlBase = String(string[string.startIndex...separatorRange.lowerBound])
            urlBase = urlBase.replacingOccurrences(of: "/sse/", with: "")
            if !urlBase.contains("//") {
                urlBase = "https://\(urlBase)"
            }

            self.urlBase.text = urlBase
            transactionID.text = String(string[separatorRange.upperBound..<string.endIndex])
        } else {
            // Only UUID
            transactionID.text = string
        }
    }

}


// MARK: - Invoice Request

extension AppearFlowController {

    private class Transfer: Decodable {
        /// Не должно быть сохранено
        var threeDs: ThreeDS?

        struct ThreeDS: Codable {
            let id: Int?
            let transaction_id: String?
            let md: String?
            let paReq: String?
            let acsUrl: String?
            let confirmUrl: String?
        }
    }
    
    /// https://test.vepay.online/h2hapi/v1#/default/get_invoices__id_
    private final class AppearInvoiceCreate: VepayBaseRequest, VepayRequest {

        typealias ResponseType = AppearFlowController.Invoice
        
        /// - Parameter uuid: ID или UUID счета, ID является устаревшим
        /// # URL Creation
        /// This method creates URL using VepayUtils.h2hURL(endpoint:, isTest). You can override h2h url using VepayUtils
        init(urlBase: String, xUser: String, accessToken: String, body: AppearInvoiceCreateBody) {
            super.init(method: .post, path: "\(urlBase)/invoices", headers: [
                "Authorization": "Bearer \(accessToken)",
                "X-User": xUser
            ], bodyEncodable: body)
        }
    }

    private struct AppearInvoiceCreateBody: Encodable {
        let transactionId: String
        private let successUrl = "https://www.site.com/success.html"
        private let failUrl = "https://www.site.com/fail.html"
        private let cancelUrl = "https://www.site.com/cancel.html"
        
        let senderCardPan: String?
        let senderCardExpMonth: String?
        let senderCardExpYear: String?
        let senderCardCvv: String?

    }

    /// https://test.vepay.online/h2hapi/v1#/default/post_invoices
    struct Invoice: Decodable {


        // MARK: - Identiry

        /// ID Счета
        /// # Example: 2735093
        let id: Int?
        /// UUID Счета
        /// # Example: 123e4567-e89b-12d3-a456-426655440000
        let uuid: String?

        let transactionId: String?

        /// Внешний идентификатор Счета. Уникальный для Мерчанта
        /// # Min Length: 1
        /// # Max Length: 40
        /// # Example: 18a2f5e5-6548-4879-88db-b272c7d6b473
        let externalId: String?

        let xUser: String?


        // MARK: - Money

        /// Сумма платежа в копейках (центах)
        /// # Min: 100
        /// # Max: 100000000
        /// # Example: 50000
        let amountFractional: Int?
        let amount: Int?

        /// Валюта Счета отправления
        /// # Example: RUB
        let currencyCode: String?

        let currencyFrom: String?
        let currencyTo: String?


        // MARK: - Info

        let provider: String?

        /// Клиент
        let client: Client?

        /// Номер договора / номер заказа
        /// # Min Length: 1
        /// # Max Length: 40
        /// # Example: КА-123/12121212
        let documentId: String?

        /// Описание
        /// # Max Length: 200
        /// # Example: Счет №1457
        let description: String?
        
        /// Redirect url for 3DS
        let redirectUrl: String?

        // MARK: - Support

        /// Статус инвойса
        let status: Status?

        /// Тайм-аут ожидания оплаты в секундах. От 10 до 59 минут. По умолчанию 15 минут.
        /// # Min: 600 # 10 * 60
        /// # Max: 3540;
        /// # Default: 15 * 60
        /// # Example: 3000
        let timeoutSeconds: Int?


        // MARK: - Sender

        let senderDocumentNumber: String?

        let senderLastName: String?
        let senderFirstName: String?
        let senderMiddleName: String?

        let senderBirthday: String?

        let senderResidenceCountry: String?
        let senderCitizenship: String?
        let senderCity: String?
        let senderAddress: String?
        let senderPhone: String?

        let recipientWallet: String?

        enum CodingKeys: CodingKey {
            case id
            case uuid
            case transactionId
            case externalId
            case xUser
            case amountFractional
            case amount
            case currencyCode
            case currencyFrom
            case currencyTo
            case provider
            case client
            case documentId
            case description
            case redirectUrl
            case status
            case timeoutSeconds
            case senderDocumentNumber
            case senderLastName
            case senderFirstName
            case senderMiddleName
            case senderBirthday
            case senderResidenceCountry
            case senderCitizenship
            case senderCity
            case senderAddress
            case senderPhone
            case recipientWallet
        }
        
        init(from decoder: any Decoder) throws {
            let container: KeyedDecodingContainer<Invoice.CodingKeys> = try decoder.container(keyedBy: Invoice.CodingKeys.self)
            self.id = try container.decodeIfPresent(Int.self, forKey: Invoice.CodingKeys.id)
            self.uuid = try container.decodeIfPresent(String.self, forKey: Invoice.CodingKeys.uuid)
            self.transactionId = try container.decodeIfPresent(String.self, forKey: Invoice.CodingKeys.transactionId)
            self.externalId = try container.decodeIfPresent(String.self, forKey: Invoice.CodingKeys.externalId)
            self.xUser = try container.decodeIfPresent(String.self, forKey: Invoice.CodingKeys.xUser)
            self.amountFractional = try container.decodeIfPresent(Int.self, forKey: Invoice.CodingKeys.amountFractional)
            self.amount = try container.decodeIfPresent(Int.self, forKey: Invoice.CodingKeys.amount)
            self.currencyCode = try container.decodeIfPresent(String.self, forKey: Invoice.CodingKeys.currencyCode)
            self.currencyFrom = try container.decodeIfPresent(String.self, forKey: Invoice.CodingKeys.currencyFrom)
            self.currencyTo = try container.decodeIfPresent(String.self, forKey: Invoice.CodingKeys.currencyTo)
            self.provider = try container.decodeIfPresent(String.self, forKey: Invoice.CodingKeys.provider)
            self.client = try container.decodeIfPresent(Invoice.Client.self, forKey: Invoice.CodingKeys.client)
            self.documentId = try container.decodeIfPresent(String.self, forKey: Invoice.CodingKeys.documentId)
            self.description = try container.decodeIfPresent(String.self, forKey: Invoice.CodingKeys.description)
            self.redirectUrl = try container.decodeIfPresent(String.self, forKey: Invoice.CodingKeys.redirectUrl)
            self.status = try container.decodeIfPresent(Invoice.Status.self, forKey: Invoice.CodingKeys.status)
            self.timeoutSeconds = try container.decodeIfPresent(Int.self, forKey: Invoice.CodingKeys.timeoutSeconds)
            self.senderDocumentNumber = try container.decodeIfPresent(String.self, forKey: Invoice.CodingKeys.senderDocumentNumber)
            self.senderLastName = try container.decodeIfPresent(String.self, forKey: Invoice.CodingKeys.senderLastName)
            self.senderFirstName = try container.decodeIfPresent(String.self, forKey: Invoice.CodingKeys.senderFirstName)
            self.senderMiddleName = try container.decodeIfPresent(String.self, forKey: Invoice.CodingKeys.senderMiddleName)
            self.senderBirthday = try container.decodeIfPresent(String.self, forKey: Invoice.CodingKeys.senderBirthday)
            self.senderResidenceCountry = try container.decodeIfPresent(String.self, forKey: Invoice.CodingKeys.senderResidenceCountry)
            self.senderCitizenship = try container.decodeIfPresent(String.self, forKey: Invoice.CodingKeys.senderCitizenship)
            self.senderCity = try container.decodeIfPresent(String.self, forKey: Invoice.CodingKeys.senderCity)
            self.senderAddress = try container.decodeIfPresent(String.self, forKey: Invoice.CodingKeys.senderAddress)
            self.senderPhone = try container.decodeIfPresent(String.self, forKey: Invoice.CodingKeys.senderPhone)
            self.recipientWallet = try container.decodeIfPresent(String.self, forKey: Invoice.CodingKeys.recipientWallet)
        }
    }
}

// MARK: - Status

extension AppearFlowController.Invoice {
    
    struct Status: Decodable {
        
        // MARK: - Proprtys
        
        /// Статус Счёта
        /// # Example: 1
        /// * 0 - В обработке
        /// * 1 - Оплачен
        /// * 2 - Отмена (Ошибка)
        /// * 3 - Возврат
        /// * 4 - Ожидается обработка
        /// * 5 - Ожидается запрос статуса
        let readable: ReadableStatus
        /// Название статуса
        /// # Example: Оплачен
        let name: String?
        /// Банк-эквайер, через который была совершена транзакция
        /// # Example: FortaTech
        let bank: String?
        /// Ошибка, если есть
        let errorInfo: String?
        /// Код ошибки от банка, если есть
        let bankErrorCode: String?
        
        
        // MARK: - Status + Codable
        
        init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<Status.CodingKeys> = try decoder.container(keyedBy: Status.CodingKeys.self)
            readable = .init(id: try container.decode(Int16.self, forKey: .id))
            name = try container.decodeIfPresent(String.self, forKey: .name)
            bank = try container.decodeIfPresent(String.self, forKey: .bank)
            errorInfo = try container.decodeIfPresent(String.self, forKey: .errorInfo)
            bankErrorCode = try container.decodeIfPresent(String.self, forKey: .bankErrorCode)
        }
        
        private enum CodingKeys: CodingKey {
            case id
            case name
            case bank
            case errorInfo
            case bankErrorCode
        }
        
        
        // MARK: - Readable Status
        
        enum ReadableStatus {
            case inProgress
            case paid
            case canceledDueToError
            case refund
            case processing
            case statusRequestAwaited
            case unknown(id: Int16)
            
            init(id: Int16) {
                switch id {
                case 0:
                    self = .inProgress
                case 1:
                    self = .paid
                case 2:
                    self = .canceledDueToError
                case 3:
                    self = .refund
                case 4:
                    self = .processing
                case 5:
                    self = .statusRequestAwaited
                default:
                    self = .unknown(id: id)
                }
            }
        }
        
    }
    
}


// MARK: - Client

extension AppearFlowController.Invoice {
    
    struct Client: Codable {
        /// ФИО клиента
        /// # Max Length: 80
        /// # Examle: Терентьев Михаил Павлович
        let fullName: String?
        /// Адрес клиента
        /// # MaxLength: 80
        /// # Examle: г. Москва, дом 5
        let address: String?
        /// # Max Length: 255
        /// # Examle: user@mail.com
        let email: String?
        /// # Max Length: 32
        /// # Examle: ExampleLogin
        let login: String?
        /// # Max Length: 32
        /// # Examle: +7999123456
        let phone: String?
        /// # Max Length: 16
        /// # Examle: 23423423
        let zip: String?
        
        init(from decoder: any Decoder) throws {
            let container: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
            self.fullName = try container.decodeIfPresent(String.self, forKey: CodingKeys.fullName)
            self.address = try container.decodeIfPresent(String.self, forKey: CodingKeys.address)
            self.email = try container.decodeIfPresent(String.self, forKey: CodingKeys.email)
            self.login = try container.decodeIfPresent(String.self, forKey: CodingKeys.login)
            self.phone = try container.decodeIfPresent(String.self, forKey: CodingKeys.phone)
            self.zip = try container.decodeIfPresent(String.self, forKey: CodingKeys.zip)
        }
    }
    
}

