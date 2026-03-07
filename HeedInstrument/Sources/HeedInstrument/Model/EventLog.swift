//
//  File.swift
//  HeedInstrument
//
//  Created by setuper on 07.03.2026.
//

import Foundation

public struct EventLog {
    
    public let timestamp: Date
    public let debug_detail: String
    
    public init(
        timestamp: Date = Date(),
        debug_detail: String
    ) {
        self.timestamp = timestamp
        self.debug_detail = debug_detail
    }
}
