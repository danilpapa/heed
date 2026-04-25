//
//  File.swift
//  HeedInstrument
//
//  Created by Данил Забинский on 25.04.2026.
//

import Foundation

public protocol HeedExporter: Sendable {
    
    func export(_ event: EventLog)
}
