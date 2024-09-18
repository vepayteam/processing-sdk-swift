//
//  AppearTransfer.swift
//  VepaySDK
//
//  Created by Bohdan Hrozian on 18.09.2024.
//

import VepaySDK

extension AppearFlowController {

    final class AppearGetTransfer: VepayBaseRequest, VepayRequest {

        typealias ResponseType = AppearFlowController.Transfer
        
        /// - Parameter uuid: ID или UUID счета, ID является устаревшим
        /// # URL Creation
        /// This method creates URL using VepayUtils.h2hURL(endpoint:, isTest). You can override h2h url using VepayUtils
        init(urlBase: String, transactionId: String, accessToken: String) {
            super.init(method: .get, path: "\(urlBase)/transactions/\(transactionId)", headers: [
                "Authorization": "Bearer \(accessToken)"
            ])
        }
    }

    class Transfer: Decodable {
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

}
