//
//  EventSource.swift
//  EventSource
//
//  Created by Andres on 2/13/15.
//  Copyright (c) 2015 Inaka. All rights reserved.
//

import Foundation


// MARK: - Main

public final class EventSource: NSObject {


    // MARK: - Configuration Parameters

    private let url: URL
    private var headers: [String: String]


    // MARK: - Session Propertys

    /// RetryTime: This can be changed remotly if the server sends an event `retry:`
    private var retryTime = 5000

    private var canAcceptNewEvent: Bool = false

    /// The last event id received from server. This id is neccesary to keep track of the last event-id received to avoid
    /// receiving duplicate events after a reconnection.
    private var lastEventID: String?

    private let operationQueue = OperationQueue()
    private var urlSession: URLSession!


    // MARK: - Handle Propertys

    private weak var delegate: EventSourceDelegate?

    private var listeningEvents: Set<String> = []

    private let eventStreamParser = EventStreamParser()
    
    
    // MARK: - Life Cycle
    
    public init(url: URL, headers: [String: String] = [:], delegate: EventSourceDelegate? = nil) {
        self.url = url
        self.headers = headers
        self.delegate = delegate

        operationQueue.maxConcurrentOperationCount = 1
        
        super.init()
    }

    deinit {
        urlSession?.invalidateAndCancel()
    }

    public func set(delegate: EventSourceDelegate!) {
        self.delegate = delegate
    }
    
}


// MARK: - Controlls

extension EventSource {

    public func connect(lastEventId: String? = nil) {
        canAcceptNewEvent = true

        urlSession = URLSession(configuration: configuration(lastEventId: lastEventId), delegate: self, delegateQueue: operationQueue)
        urlSession.dataTask(with: url).resume()
    }

    /// Reconnecting using lastEventID
    public func reconnect() {
        connect(lastEventId: lastEventID)
    }

    public func disconnect() {
        canAcceptNewEvent = false
        urlSession?.invalidateAndCancel()
        urlSession = nil
    }

    /// Start listening to event with specific name
    public func listen(to eventName: String) {
        listeningEvents.insert(eventName)
    }

    /// Stop listening to event with specific name
    public func stopListen(to eventName: String) {
        listeningEvents.remove(eventName)
    }
    
}


// MARK: - URL Session

extension EventSource: URLSessionDataDelegate {

    // #1 Open
    public func urlSession(_ session: URLSession,
                         dataTask: URLSessionDataTask,
                         didReceive response: URLResponse,
                         completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        completionHandler(URLSession.ResponseDisposition.allow)
        delegate?.connected()
    }

    // #2 Configure
    public func urlSession(_ session: URLSession,
                         task: URLSessionTask,
                         willPerformHTTPRedirection response: HTTPURLResponse,
                         newRequest request: URLRequest,
                         completionHandler: @escaping (URLRequest?) -> Void) {
        var newRequest = request
        self.headers.forEach { newRequest.setValue($1, forHTTPHeaderField: $0) }
        completionHandler(newRequest)
    }

    // #3 Accept Event
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        if canAcceptNewEvent {
            for event in eventStreamParser.parse(data: data) {
                lastEventID = event.id
                if let retryTime = event.retryTime {
                    self.retryTime = retryTime
                }

                if event.onlyRetryEvent == true {
                    continue
                }
                
                if (event.name != nil && listeningEvents.contains(event.name!)) {
                    delegate?.newListened(event: event)
                } else {
                    delegate?.new(event: event)
                }
            }
        }
    }

    // Error
    public func urlSession(_ session: URLSession,
                         task: URLSessionTask,
                         didCompleteWithError error: Error?) {
        if let statusCode = (task.response as? HTTPURLResponse)?.statusCode {

            // Following "5 Processing model" from:
            // https://www.w3.org/TR/2009/WD-eventsource-20090421/#handler-eventsource-onerror
            let canReconnect: Bool = (200...300).contains(statusCode)

            canAcceptNewEvent = false
            delegate?.error(sse: self, canReconnect: canReconnect, statusCode: statusCode, description: error?.localizedDescription)
        }

    }

}


// MARK: - Configuration

private extension EventSource {

    private func configuration(lastEventId: String?) -> URLSessionConfiguration {
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.timeoutIntervalForRequest = TimeInterval(INT_MAX)
        sessionConfiguration.timeoutIntervalForResource = TimeInterval(INT_MAX)


        if let eventID = lastEventId {
            headers["Last-Event-Id"] = eventID
        }
        sessionConfiguration.httpAdditionalHeaders = headers

        sessionConfiguration.httpAdditionalHeaders!["Cache-Control"] = "no-cache"
        sessionConfiguration.httpAdditionalHeaders!["Content-Type"] = "text/event-stream"

        return sessionConfiguration
    }

}
