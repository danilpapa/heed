//
//  UINavigationControllerSwizzling.swift
//  HeedInstrument
//
//  Created by setuper on 25.03.2026.
//

import UIKit
import ObjectiveC.runtime

public final class UINavigationControllerSwizzling: IHeedSwizzling {

    public static func enable() {
        let cls: AnyClass = UINavigationController.self

        swap(cls, #selector(UINavigationController.pushViewController(_:animated:)), #selector(UINavigationController.hs_instrumented_pushViewController(_:animated:)))
        swap(cls, #selector(UINavigationController.popViewController(animated:)), #selector(UINavigationController.hs_instrumented_popViewController(animated:)))
        swap(cls, #selector(UINavigationController.popToRootViewController(animated:)), #selector(UINavigationController.hs_instrumented_popToRootViewController(animated:)))
        swap(cls, #selector(UINavigationController.popToViewController(_:animated:)), #selector(UINavigationController.hs_instrumented_popToViewController(_:animated:)))
    }

    private static func swap(_ cls: AnyClass, _ original: Selector, _ swizzled: Selector) {
        guard
            let originalMethod = class_getInstanceMethod(cls, original),
            let swizzledMethod = class_getInstanceMethod(cls, swizzled)
        else { return }
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
}
