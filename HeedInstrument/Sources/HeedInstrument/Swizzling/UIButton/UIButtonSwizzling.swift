//
//  File.swift
//  HeedInstrument
//
//  Created by setuper on 07.03.2026.
//

import UIKit
import ObjectiveC.runtime

public final class UIButtonSwizzling: IHeedSwizzling {
    
    public static func enable() {
        guard
            let originalMethod = class_getInstanceMethod(
                UIControl.self,
                #selector(UIControl.sendAction(_:to:for:))
            ),
            let swizzedMethod = class_getInstanceMethod(
                UIControl.self,
                #selector(UIControl.hs_instrumented_sendAction(_:to:for:))
            )
        else { return }
        
        method_exchangeImplementations(originalMethod, swizzedMethod)
    }
}
