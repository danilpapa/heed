//
//  UITableViewSwizzling.swift
//  HeedInstrument
//
//  Created by setuper on 23.03.2026.
//

import UIKit
import ObjectiveC.runtime

public final class UITableViewSwizzling: IHeedSwizzling {

    public static func enable() {
        let cls: AnyClass = UITableView.self

        let originalSel = #selector(setter: UITableView.delegate)
        let swizzledSel = #selector(UITableView.hs_instrumented_setDelegate(_:))

        guard
            let original = class_getInstanceMethod(cls, originalSel),
            let swizzled = class_getInstanceMethod(cls, swizzledSel)
        else { return }

        method_exchangeImplementations(original, swizzled)
    }
}
