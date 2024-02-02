//
//  EventSource+Support.swift
//  VepaySDK
//
//  Created by Bohdan Hrozian on 26.01.2024.
//

public protocol EventSourceDelegate: NSObject {
    /// Called when SSE has successfully connected to the server.
    func connected()

    /// Called when SSE has successfully disconnected to the server.
    func disconnected()

    /// Called everytime any event that is not specificly listened to is received.
    func new(event: EventSource.Event)

    /// Called when listented event is received.
    func newListened(event: EventSource.Event)

    /// When any error occured this method is called and SSE session is invalidated, you can call tryReconnect
    func error(sse: EventSource, canReconnect: Bool, statusCode: Int, description: String?)

}


extension EventSourceDelegate {
    
    public func connected() { }
    public func disconnected() { }
    public func new(event: EventSource.Event) { }
    public func newListened(event: EventSource.Event) { }

    public func error(sse: EventSource, canReconnect: Bool, statusCode: Int, description: String?) {
        if canReconnect { sse.reconnect() } else {
            print( "\nSSE Error:\n - Status Code: \(statusCode)")
            if description != nil {
                print(" - \(description!)")
            }
        }
    }

}
