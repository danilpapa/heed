//
//  File.swift
//  HeedInstrument
//
//  Created by Данил Забинский on 25.04.2026.
//

import Foundation
import Network

public final class UDPExporter {
    
    private let connection: NWConnection
    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()
    
    public init(
        host: String = "127.0.0.1",
        port: UInt16 = 9876,
    ) {
        self.connection = NWConnection(
            host: NWEndpoint.Host(host),
            port: NWEndpoint.Port(rawValue: port)!,
            using: .udp
        )
        connection.start(queue: .global(qos: .utility))
    }
}

extension UDPExporter: HeedExporter {
    
    public func export(_ event: EventLog) {
        guard let data = try? encoder.encode(event) else { return }
        connection.send(content: data, completion: .idempotent)
    }
}
