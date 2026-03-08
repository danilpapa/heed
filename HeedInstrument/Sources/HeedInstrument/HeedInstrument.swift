//
//  File.swift
//  HeedInstrument
//
//  Created by setuper on 08.03.2026.
//

import Foundation

public final class HeedInstrument {
    
    public static func start() {
        Heed.invoke {
            UIButtonSwizzling.self
        }
    }
}
