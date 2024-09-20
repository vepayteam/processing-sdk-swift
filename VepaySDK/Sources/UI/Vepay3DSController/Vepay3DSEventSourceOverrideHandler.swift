//
//  Vepay3DSEventSourceOverrideHandler.swift
//  VepaySDK
//
//  Created by Bohdan Hrozian on 14.09.2024.
//

//import LDSwiftEventSource

/// Allows to customize specific part of behavior. All methods are optional (by default they return true aka continue default behavior), so you can override specific method
public protocol Vepay3DSEventSourceOverrideHandler: NSObject {
    
    /// - Returns: Override SSE.onOpened
    /// # By Default
    /// Vepay3DSController does nothing
    func onOpened()
    
    /// - Returns: Tells cotroller to contrinue default behavior, or exit. If true, Vepay3DSController will contrinue, if false, controller will exit
    /// # By Default
    /// Calls delegate.threeDSFninished(status: .inProgress) and drops sse
    func onClosed() -> Bool

    /// - Returns: Tells cotroller to contrinue default behavior, or exit. If true, Vepay3DSController will contrinue, if false, controller will exit
    /// # By Default
    /// Controller will check is status in message. If status isnt nil, if will try to parse it and call delegate.threeDSFninished(status: parsedStatus ?? .inProgress)
    func onMessage(eventType: String, messageEvent: MessageEvent) -> Bool
    
    /// - Returns: Tells cotroller to contrinue default behavior, or exit. If true, Vepay3DSController will contrinue, if false, controller will exit
    /// # By Default
    /// Vepay3DSController does nothing
    func onComment(comment: String)

    /// - Returns: Tells cotroller to contrinue default behavior, or exit. If true, Vepay3DSController will contrinue, if false, controller will exit.
    /// # By Default
    /// On error will close sse and delegate.threeDSFninished(status: .inProgress)
    /// # You Can Override
    /// for example to reopen connection or creation new SSE
    func onError(error: any Error) -> Bool

}

public extension Vepay3DSEventSourceOverrideHandler {
    func onOpened() { }
    func onClosed() -> Bool { true }
    func onMessage(eventType: String, messageEvent: MessageEvent) -> Bool { true }
    func onComment(comment: String) { }
    func onError(error: any Error) -> Bool { true }
}

// MARK: - Vepay3DSControllerDelegate

public protocol Vepay3DSControllerDelegate: NSObject {
    
    /// When SSE message contains status, this method is called
    /// # Default Behavior
    /// Returns true, sse will close, if false sse continue accept events
    /// About default behavior you can read in Vepay3DSController description
    func sseUpdated(int: Int8?, string: String?) -> Bool
    func sseClosed()
}
