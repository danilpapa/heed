//
//  File.swift
//  HeedInstrument
//
//  Created by setuper on 07.03.2026.
//

import Foundation

public struct EventLog: Codable {
    
    public let timestamp: Date
    public let category: String
    public let eventType: String
    public let duration: TimeInterval
    public let detail: String
    
    public init(
        timestamp: Date = Date(),
        category: String,
        eventType: String,
        duration: TimeInterval = 0,
        detail: String
    ) {
        self.timestamp = timestamp
        self.category = category
        self.eventType = eventType
        self.duration = duration
        self.detail = detail
    }
}
