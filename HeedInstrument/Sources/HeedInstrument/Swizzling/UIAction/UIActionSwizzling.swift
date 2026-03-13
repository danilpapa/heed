//
//  UIActionSwizzling.swift
//  HeedInstrument
//
//  Created by setuper on 13.03.2026.
//

import UIKit
import ObjectiveC.runtime

public final class UIActionSwizzling: IHeedSwizzling {

    public static func enable() {
        let cls: AnyClass = UIAction.self

        let originalInitHandler = NSSelectorFromString("initWithHandler:")
        let swizzledInitHandler = NSSelectorFromString("hs_instrumented_initWithHandler:")
        if let original = class_getInstanceMethod(cls, originalInitHandler),
           let swizzled = class_getInstanceMethod(cls, swizzledInitHandler) {
            method_exchangeImplementations(original, swizzled)
        }

        let originalInitTitle = NSSelectorFromString("initWithTitle:image:identifier:discoverabilityTitle:attributes:state:handler:")
        let swizzledInitTitle = NSSelectorFromString("hs_instrumented_initWithTitle:image:identifier:discoverabilityTitle:attributes:state:handler:")
        if let original = class_getInstanceMethod(cls, originalInitTitle),
           let swizzled = class_getInstanceMethod(cls, swizzledInitTitle) {
            method_exchangeImplementations(original, swizzled)
        }
    }
}
