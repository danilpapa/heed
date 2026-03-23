//
//  UITextFieldSwizzling.swift
//  HeedInstrument
//
//  Created by setuper on 23.03.2026.
//

import UIKit
import ObjectiveC.runtime

public final class UITextFieldSwizzling: IHeedSwizzling {

    public static func enable() {
        let cls: AnyClass = UITextField.self

        let originalSel = #selector(UITextField.didMoveToWindow)
        let swizzledSel = #selector(UITextField.hs_instrumented_didMoveToWindow)

        guard
            let original = class_getInstanceMethod(cls, originalSel),
            let swizzled = class_getInstanceMethod(cls, swizzledSel)
        else { return }

        method_exchangeImplementations(original, swizzled)
    }
}
