//
//  VepayBankCard.swift
//  VepaySDK
//
//  Created by Bohdan Hrozian on 09.01.2024.
//

// MARK: - VepayCard

/// https://api.vepay.online/mfo#/Card/post_card_get
public final class VepayCard: Decodable {

    /// Идентификатор карты
   public var id: Int!

    /// Номер карты
   public var number: String!

    /// Срок действия (мм/гг)
   public var expire: String!

    /// Держатель карты
   public var holder: String!

    /// Система оплаты. Возможные значения: VISA, MASTERCARD, MIR, AMERICAN EXPRESS, JCB, DINNERSCLUB, MAESTRO, DISCOVER, CHINA UNIONPAY
   public var paymentSystemName: String!

   public var bank: VepayBank?

    public var paymentSystem: VepayCardType?


    // MARK: - Empty Init

    /// Empty init for card registration
    public init() { }


    // MARK: - Valued Init

    public init(id: Int, number: String, expire: String, holder: String, paymentService: VepayCardType, bank: VepayBank? = nil) {
        self.id = id
        self.number = number
        self.expire = expire
        self.holder = holder
        self.paymentSystemName = paymentService.name
        self.paymentSystem = paymentService
        self.bank = bank
    }

    
    // MARK: - Decodable

    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case number = "num"
        case expire = "exp"
        case holder = "holder"
        case paymentSystem = "payment_system"
    }


    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.number = try container.decode(String.self, forKey: .number)
        self.expire = try container.decode(String.self, forKey: .expire)
        self.holder = try container.decode(String.self, forKey: .holder)
        self.paymentSystemName = try container.decode(String.self, forKey: .paymentSystem)
    }

}
