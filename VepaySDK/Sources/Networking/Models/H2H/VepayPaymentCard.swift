//
//  VepayPaymentCard.swift
//  VepaySDK
//
//  Created by Bohdan Hrozian on 22.01.2024.
//

// MARK: - Card

public final class VepayPaymentCard: Codable {

    /// Номер карты. В ответе замаскирован.
    /// # Example: 4111111111111111
    public let cardNumber: String

    /// Держатель карты
    /// # Example: Terentiev Mihail
    public let cardHolder: String

    /// Месяц / год карты
    /// # Min Length: 4
    /// # Max Length: 4
    /// # Example: 0122
    public let expires: String

    /// CVC
    /// # Min Length: 3
    /// # Max Length: 3
    /// # Example: 123
    public let cvc: String?

    public init(cardNumber: String, cardHolder: String, expires: String, cvc: String) {
        self.cardNumber = cardNumber
        self.cardHolder = cardHolder
        self.expires = expires
        self.cvc = cvc
    }

    public init?(card: VepayCard, cvv: String!) {
        if card.number != nil, card.holder != nil, card.expire != nil, cvv != nil {
            self.cardNumber = card.number
            self.expires = card.expire
            self.cardHolder = card.holder
            self.cvc = cvv
        } else {
            return nil
        }
    }

}
