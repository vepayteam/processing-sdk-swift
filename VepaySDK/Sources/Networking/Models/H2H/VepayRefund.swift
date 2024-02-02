//
//  VepayRefund.swift
//  VepaySDK
//
//  Created by Bohdan Hrozian on 09.01.2024.
//


// MARK: - Refund

public struct VepayRefund: Decodable {
    
    /// Сумма возврата в копейках (центах). null - полный возврат.
    /// # Min: 100
    /// # Max: 100000000
    /// # Example: 50000
    public let amountFractional: Int?

    /// ID Возврата
    /// # Example: 1241423
    public let id: Int

    /// Статус оплаты Счета:
    /// * 2 - Ошибка
    /// * 4 - Ожидается обработка
    /// * 6 - Возврат произведен
    /// # Example: 4
    public let status: Int

    /// Сообщение и текст ошибки
    /// # Example: Возврат произведен
    public let message: String
    
}
