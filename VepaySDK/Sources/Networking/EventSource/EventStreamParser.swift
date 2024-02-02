//
//  EventStreamParser.swift
//  EventSource
//
//  Created by Andres on 30/05/2019.
//  Copyright © 2019 inaka. All rights reserved.
//

import Foundation

public final class EventStreamParser {

    //  Events are separated by end of line. End of line can be:
    //  \r = CR (Carriage Return) → Used as a new line character in Mac OS before X
    //  \n = LF (Line Feed) → Used as a new line character in Unix/Mac OS X
    //  \r\n = CR + LF → Used as a new line character in Windows
    private let newlineCharacters: Set<String>
    private let delimiters: Set<Data>

    public init() {
        newlineCharacters = ["\r\n", "\n", "\r"]
        delimiters = Set(newlineCharacters.map { "\($0)\($0)".data(using: String.Encoding.utf8)! })
    }

    public func parse(data: Data) -> [EventSource.Event] {
        var events: [EventSource.Event] = []

        // Search For Events
        var searchRange = Range(NSRange(location: .zero, length: data.count))!
        while let foundRange = searchForDelimiter(in: searchRange, data: data) {

            let chankRange = NSRange(location: searchRange.lowerBound, length: foundRange.lowerBound - searchRange.lowerBound)
            if let eventString = String(bytes: data[Range(chankRange)!], encoding: .utf8),
                let event = EventSource.Event(eventString: eventString, newLineCharacters: newlineCharacters) {
                events.append(event)
            }

            searchRange = Range(NSRange(location: foundRange.upperBound, length: data.count - foundRange.upperBound))!
        }

        return events
    }

    private func searchForDelimiter(in range: Range<Data.Index>, data: Data) -> Range<Data.Index>? {
        for delimiter in delimiters {
            if let foundedRange = data.range(of: delimiter, in: range) {
                return foundedRange
            }
        }

        return nil
    }

}
