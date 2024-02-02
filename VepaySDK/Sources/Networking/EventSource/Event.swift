//
//  Event.swift
//  EventSource
//
//  Created by Andres on 01/06/2019.
//  Copyright © 2019 inaka. All rights reserved.
//

import Foundation

extension EventSource {

    public struct Event {
        public let id: String?
        public let name: String?
        public let data: String?
        public let retryTime: Int?

        public let onlyRetryEvent: Bool

        public init?(eventString: String?, newLineCharacters: Set<String>) {
            if let eventString = eventString, !eventString.hasPrefix(":") {
                self = Event.parseEvent(eventString, newLineCharacters: newLineCharacters)
            } else {
                return nil
            }
        }

        public init(id: String?, name: String?, data: String?, retryTime: String?) {
            self.id = id
            self.name = name
            self.data = data
            self.retryTime = (retryTime != nil) ? Int(retryTime!) : nil
            self.onlyRetryEvent = (id == nil && name == nil && data == nil) && retryTime != nil
        }
        
    }

}

private extension EventSource.Event {
        
    static func parseEvent(_ eventString: String, newLineCharacters: Set<String>) -> EventSource.Event {
        var event: [String: String] = [:]
        
        for line in eventString.components(separatedBy: CharacterSet.newlines) as [String] {
            let (akey, value) = EventSource.Event.parseLine(line, newLineCharacters: newLineCharacters)
            guard let key = akey else { continue }
            
            if let value = value, let previousValue = event[key] ?? nil {
                event[key] = "\(previousValue)\n\(value)"
            } else if let value = value {
                event[key] = value
            } else {
                event[key] = nil
            }
        }
        
        // the only possible field names for events are: id, event and data. Everything else is ignored.
        return .init(
            id: event["id"],
            name: event["event"],
            data: event["data"],
            retryTime: event["retry"])
    }

    static func parseLine(_ line: String, newLineCharacters: Set<String>) -> (key: String?, value: String?) {
        let scanner = Scanner(string: line)
        let key: String?
        var value: String? = nil

        if #available(iOS 13.0, *) {
            key = scanner.scanUpToString(":")
            _ = scanner.scanString(":")
        } else {
            var _key: NSString?
            scanner.scanUpTo(":", into: &_key)
            scanner.scanString(":", into: nil)
            key = _key as? String
        }

        for newline in newLineCharacters {
            if #available(iOS 13.0, *) {
                value = scanner.scanUpToString(newline)
                if value != nil {
                    break
                }
            } else {
                var _value: NSString? = nil
                if scanner.scanUpTo(newline, into: &_value) {
                    value = _value as? String
                    break
                }
            }
        }
        
        // for id and data if they come empty they should return an empty string value.
        if key != "event" && value == nil {
            value = ""
        }
        
        return (key, value)
    }

}

