//
//  File.swift
//  HeedInstrument
//
//  Created by setuper on 08.03.2026.
//

import UIKit

@resultBuilder
final class SwizzledBuilder {
    
    static func buildBlock(_ components: IHeedSwizzling.Type...) -> [IHeedSwizzling.Type] {
        components
    }
}

public enum HeedInstruments {
    
    public static func invoke(@SwizzledBuilder builder: () -> [IHeedSwizzling.Type]) {
        builder().forEach { $0.enable() }
    }
}
