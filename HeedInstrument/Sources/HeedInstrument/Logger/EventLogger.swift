//
//  File.swift
//  HeedInstrument
//
//  Created by setuper on 07.03.2026.
//

import Foundation

public final class EventLogger: Sendable {
    
    public static let shared = EventLogger()
    
    private init() { }
    
    public func log(_ event: EventLog) {
        print("""
        [UI EVENT]
        time: \(event.timestamp)
        detail: \(event.debug_detail)
        """)
    }
}
