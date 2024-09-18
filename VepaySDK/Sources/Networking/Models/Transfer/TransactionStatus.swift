//
//  TransferStatus.swift
//  VepaySDK
//
//  Created by Bohdan Hrozian on 18.09.2024.
//

public enum TransactionStatus {
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
    
    case unknown(int: Int8?, string: String?)

    public var isFailed: Bool {
        if case .failed = self { true
        } else { false }
    }
    public var isSuccess: Bool {
        if case .done = self { true
        } else { false }
    }
    
    public init(status: Int8) {
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
        default:
            self = .unknown(int: status, string: nil)
        }
    }
    
    public init(status: String) {
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
        default:
            self = .unknown(int: nil, string: status)
        }
    }

}
