//
//  File.swift
//  HeedInstrument
//
//  Created by setuper on 07.03.2026.
//

import Foundation

public final class EventLogger: Sendable {
    
    public static let shared = EventLogger()
    nonisolated(unsafe) private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    nonisolated(unsafe) private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()
    
    private init() { }
    
    public func log(_ event: EventLog) {
        let date = EventLogger.dateFormatter.string(from: event.timestamp)
        let time = EventLogger.timeFormatter.string(from: event.timestamp)
        let durationMs = Int((event.duration * 1000).rounded())
        print("\(date) | \(time) | \(event.category) \(event.eventType) | \(durationMs)ms | \(event.detail)")
    }
}
