//
//  VepayInvoiceCreation.swift
//  VepaySDK
//
//  Created by Bohdan Hrozian on 07.01.2024.
//


// MARK: - Invoice

/// https://test.vepay.online/h2hapi/v1#/default/post_invoices
public struct VepayInvoice: Codable {


    // MARK: - Required Propertys

    /// Сумма платежа в копейках (центах)
    /// # Min: 100
    /// # Max: 100000000
    /// # Example: 50000
    public let amountFractional: Int

    /// Валюта Счета
    /// # [ RUB, USD, EUR ]
    /// # Example: RUB
    public let currencyCode: String

    /// Внешний идентификатор Счета. Уникальный для Мерчанта
    /// # Min Length: 1
    /// # Max Length: 40
    /// # Example: 18a2f5e5-6548-4879-88db-b272c7d6b473
    public let externalId: String

    /// Клиент
    public let client: VepayClient


    // MARK: - Optional Propertys

    /// ID Счета
    /// # Example: 2735093

    public let id: Int?
    /// UUID Счета
    /// # Example: 123e4567-e89b-12d3-a456-426655440000
    public let uuid: String?

    /// Номер договора / номер заказа
    /// # Min Length: 1
    /// # Max Length: 40
    /// # Example: КА-123/12121212
    public let documentId: String?

    /// Описание
    /// # Max Length: 200
    /// # Example: Счет №1457
    public let description: String?

    /// Тайм-аут ожидания оплаты в секундах. От 10 до 59 минут. По умолчанию 15 минут.
    /// # Min: 600 # 10 * 60
    /// # Max: 3540;
    /// # Default: 15 * 60
    /// # Example: 3000
    public let timeoutSeconds: Int?

    /// URL для возврата после завершения платежа (успех)
    /// # Example: https://www.site.com/example.html
    public let successUrl: String?

    /// URL для возврата после завершения платежа (ошибка)
    /// # Example: https://www.site.com/example.html
    public let failUrl: String?

    /// URL для возврата после отказа от оплаты
    /// # Example: https://www.site.com/example.html
    public let cancelUrl: String?

    /// Статус инвойса
    public let status: VepayStatus?

    public let card: VepayPaymentCard?
    /// Данные для перенаправления пользователя на страницу ACS (проверка 3DS), если надо
    public let acsRedirect: VepayPaymentResponse.Redirect?


    // MARK: - Init

    public init(amountFractional: Int, currency: String, externalId: String, client: VepayClient, id: Int? = nil, uuid: String? = nil, documentId: String?, description: String?, timeoutSeconds: Int = 3000, successUrl: String? = nil, failUrl: String? = nil, cancelUrl: String? = nil, status: VepayStatus? = nil, card: VepayPaymentCard? = nil, acsRedirect: VepayPaymentResponse.Redirect? = nil) {
        self.amountFractional = amountFractional
        self.currencyCode = currency
        self.externalId = externalId
        self.client = client
        self.id = id
        self.uuid = uuid
        self.documentId = documentId
        self.description = description
        self.timeoutSeconds = timeoutSeconds
        self.successUrl = successUrl
        self.failUrl = failUrl
        self.cancelUrl = cancelUrl
        self.status = status
        self.card = card
        self.acsRedirect = acsRedirect
    }


    /// Simple version of init for creating invoice
    public init(amountFractional: Int, currency: String, externalId: String = UUID().uuidString, client: VepayClient, documentId: String?, description: String?, timeoutSeconds: Int = 3000) {
        self.amountFractional = amountFractional
        self.currencyCode = currency
        self.externalId = externalId
        self.client = client
        self.documentId = documentId
        self.description = description
        self.timeoutSeconds = timeoutSeconds
        self.id = nil
        self.uuid = nil
        self.successUrl = nil
        self.failUrl = nil
        self.cancelUrl = nil
        self.status = nil
        self.card = nil
        self.acsRedirect = nil
    }

}


// MARK: - Status

extension VepayInvoice {

    public struct VepayStatus: Codable {
        
        // MARK: - Proprtys

        /// Статус Счёта
        /// # Example: 1
        /// * 0 - В обработке
        /// * 1 - Оплачен
        /// * 2 - Отмена (Ошибка)
        /// * 3 - Возврат
        /// * 4 - Ожидается обработка
        /// * 5 - Ожидается запрос статуса
        public let id: Int
        public var readable: ReadableStatus? { .init(rawValue: Int8(id))}
        /// Название статуса
        /// # Example: Оплачен
        public let name: String
        /// Банк-эквайер, через который была совершена транзакция
        /// # Example: FortaTech
        public let bank: String
        /// Ошибка, если есть
        public let errorInfo: String?
        /// Код ошибки от банка, если есть
        public let bankErrorCode: String?


        // MARK: - Status + Codable

        public init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<VepayInvoice.VepayStatus.CodingKeys> = try decoder.container(keyedBy: VepayInvoice.VepayStatus.CodingKeys.self)
            id = try container.decode(Int.self, forKey: .id)
            name = try container.decode(String.self, forKey: .name)
            bank = try container.decode(String.self, forKey: .bank)
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

        public enum ReadableStatus: Int8 {
            case inProgress = 0
            case paid = 1
            case canceledDueToError = 2
            case refund = 3
            case processing = 4
            case statusRequestAwaited = 5
        }
    }

}


// MARK: - Client

extension VepayInvoice {

    public struct VepayClient: Codable {
        /// ФИО клиента
        /// # Max Length: 80
        /// # Examle: Терентьев Михаил Павлович
        public let fullName: String
        /// Адрес клиента
        /// # MaxLength: 80
        /// # Examle: г. Москва, дом 5
        public let address: String
        /// # Max Length: 255
        /// # Examle: user@mail.com
        public let email: String
        /// # Max Length: 32
        /// # Examle: ExampleLogin
        public let login: String
        /// # Max Length: 32
        /// # Examle: +7999123456
        public let phone: String
        /// # Max Length: 16
        /// # Examle: 23423423
        public let zip: String

        public init(fullName: String, address: String, email: String, login: String, phone: String, zip: String) {
            self.fullName = fullName
            self.address = address
            self.email = email
            self.login = login
            self.phone = phone
            self.zip = zip
        }

    }
    
}
