//
//  UIControlAddActionSwizzling.swift
//  HeedInstrument
//
//  Created by setuper on 13.03.2026.
//

import UIKit
import ObjectiveC.runtime

public final class UIControlAddActionSwizzling: IHeedSwizzling {

    public static func enable() {
        let cls: AnyClass = UIControl.self

        let originalSel = NSSelectorFromString("addAction:forControlEvents:")
        let swizzledSel = NSSelectorFromString("hs_instrumented_addAction:forControlEvents:")

        guard
            let original = class_getInstanceMethod(cls, originalSel),
            let swizzled = class_getInstanceMethod(cls, swizzledSel)
        else { return }

        method_exchangeImplementations(original, swizzled)
    }
}
