//
//  UIViewControllerSwizzling.swift
//  HeedInstrument
//
//  Created by setuper on 25.03.2026.
//

import UIKit
import ObjectiveC.runtime

public final class UIViewControllerSwizzling: IHeedSwizzling {

    public static func enable() {
        let cls: AnyClass = UIViewController.self

        swap(cls, #selector(UIViewController.viewDidLoad), #selector(UIViewController.hs_instrumented_viewDidLoad))
        swap(cls, #selector(UIViewController.viewWillAppear(_:)), #selector(UIViewController.hs_instrumented_viewWillAppear(_:)))
        swap(cls, #selector(UIViewController.viewDidAppear(_:)), #selector(UIViewController.hs_instrumented_viewDidAppear(_:)))
        swap(cls, #selector(UIViewController.viewWillDisappear(_:)), #selector(UIViewController.hs_instrumented_viewWillDisappear(_:)))
        swap(cls, #selector(UIViewController.viewDidDisappear(_:)), #selector(UIViewController.hs_instrumented_viewDidDisappear(_:)))
        swap(cls, #selector(UIViewController.present(_:animated:completion:)), #selector(UIViewController.hs_instrumented_present(_:animated:completion:)))
    }

    private static func swap(_ cls: AnyClass, _ original: Selector, _ swizzled: Selector) {
        guard
            let originalMethod = class_getInstanceMethod(cls, original),
            let swizzledMethod = class_getInstanceMethod(cls, swizzled)
        else { return }
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
}
