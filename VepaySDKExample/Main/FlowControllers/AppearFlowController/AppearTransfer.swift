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
        var status: TransactionStatus
        var threeDs: ThreeDS?

        enum CodingKeys: CodingKey {
            case status
            case threeDs
        }
        required init(from decoder: any Decoder) throws {
            let container: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
            self.status = .init(status: try container.decode(Int8.self, forKey: CodingKeys.status))
            self.threeDs = try container.decodeIfPresent(ThreeDS.self, forKey: CodingKeys.threeDs)
        }
        
        struct ThreeDS: Codable {
            let id: Int?
            let transaction_id: String?
            let md: String?
            let paReq: String?
            let acsUrl: String?
            let confirmUrl: String?
        }
    }

    enum TransactionStatus {
        /// 0 - FAILED: The transaction has failed.
        case failed
        /// 1 - INITIATED: The transaction has been initiated but not processed yet.
        case initiated
        /// 2 - PROCESSING: The transaction is currently being processed.
        case processing
        /// 3 - DONE: The transaction is completed.
        case done
        /// 4 - PENDING: The transaction is awaiting further action.
        case pending
        /// 5 - PAID: The transaction's invoice is paid.
        case paid
        /// The transaction's invoice wasn't finished for some reason
        case invoiceFailed
        /// 7 - Some action needed
        case needAction
        /// 8 - 3DS are needed
        case need3DS

        case unknown(int: Int8?, string: String?)
        
        init(status: Int8) {
            switch status {
            case .zero:
                self = .failed
            case 1:
                self = .initiated
            case 2:
                self = .processing
            case 3:
                self = .done
            case 4:
                self = .pending
            case 5:
                self = .paid
            case 6:
                self = .invoiceFailed
            case 7:
                self = .needAction
            case 8:
                self = .need3DS
            default:
                self = .unknown(int: status, string: nil)
            }
        }
        
        init(status: String) {
            switch status {
            case "INITIATED":
                self = .initiated
            case "PROCESSING":
                self = .processing
            case "DONE":
                self = .done
            case "FAILED":
                self = .failed
            case "PENDING":
                self = .pending
            case "PAID":
                self = .paid
            case "INVOICE_FAILED":
                self = .invoiceFailed
            case "NEEDACTION", "NEED_ACTION":
                self = .needAction
            case "NEEDDS", "NEED_3DS":
                self = .need3DS
            default:
                self = .unknown(int: nil, string: status)
            }
        }

        var title: String {
            switch self {
            case .failed:
                "Failed"
            case .initiated:
                "Initiated"
            case .processing:
                "In Progress"
            case .done:
                "Done"
            case .pending:
                "Pending"
            case .paid:
                "Paid"
            case .invoiceFailed:
                "Invoice Failed"
            case .needAction:
                "Need Action"
            case .need3DS:
                "Need 3DS"
            case .unknown(let int, let string):
                "Unknown Status: \(int != nil ? "\(int!)" : string ?? "Empty")"
            }
        }
    }

}
