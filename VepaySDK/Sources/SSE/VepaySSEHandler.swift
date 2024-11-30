//
//  VepaySSEHandler.swift
//  VepaySDK
//
//  Created by Bohdan Hrozian on 11/30/24.
//

import Foundation

/// Stores and handles SSE
open class VepaySSEHandler: EventHandler {

    
    // MARK: - Propertys

    /// You can set SSE using set(sse:) or start(sse)
    public private(set) var sse: EventSource?

    public weak var delegate: VepaySSEHandlerDelegate?


    // MARK: - Life Cycle

    /// Create and start SSE from url
    /// - Parameters:
    ///   - url: url for SSE
    ///   - delegate: if nil, Vepay3DSController will handle events
    open func set(sse: URL,
                  configure: (EventSource.Config) -> (EventSource.Config) = { $0 },
                  connectionErrorHandler: @escaping VepayConnectionErrorHandler = { _ in .shutdown },
                  start: Bool = true) {
        var config = EventSource.Config(handler: self, url: sse)
        config.connectionErrorHandler = connectionErrorHandler
        self.sse = EventSource(config: configure(config))
        if start {
            self.sse?.start()
        }
    }

    open func stopSSEAndNullify() {
        sse?.stop()
        sse = nil
    }


    // MARK: - Handling

    open func onMessage(eventType: String, messageEvent: MessageEvent) {
        guard messageEvent.data.contains("status") else { return }
        let data = messageEvent.data.replacingOccurrences(of: "\"", with: "", options: .regularExpression)
        if let statusUpperBound = data.range(of: "status:")?.upperBound {
            var int: Int8? = nil
            var string: String? = nil
            if let statusInt = Int8(String(data[statusUpperBound])) {
                int = statusInt
            } else {
                let endIndex = data.range(of: ",", range: .init(uncheckedBounds: (lower: statusUpperBound, upper: data.endIndex)))?.lowerBound ?? data.endIndex
                string = data[statusUpperBound...endIndex].replacingOccurrences(of: "[^A-Z]", with: "", options: .regularExpression)
            }

            if delegate?.sseUpdated(int: int, string: string) ?? true {
                stopSSEAndNullify()
            }
        }
    }

    open func onError(error: any Error) {
        delegate?.sseClosed()
        stopSSEAndNullify()
    }

    open func onOpened() { }

    open func onClosed() {
        delegate?.sseClosed()
    }

    open func onComment(comment: String) { }

}


// MARK: - VepaySSEHandlerDelegate

public protocol VepaySSEHandlerDelegate: NSObject {
    
    /// When SSE message contains status, this method is called
    /// # Default Behavior
    /// Returns true, sse will close, if false sse continue accept events
    /// About default behavior you can read in Vepay3DSController description
    func sseUpdated(int: Int8?, string: String?) -> Bool
    func sseClosed()

}
