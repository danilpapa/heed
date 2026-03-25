//
//  UINavigationController+.swift
//  HeedInstrument
//
//  Created by setuper on 25.03.2026.
//

import UIKit

extension UINavigationController {

    @objc func hs_instrumented_pushViewController(_ viewController: UIViewController, animated: Bool) {
        let fromType = String(describing: type(of: topViewController ?? UIViewController()))
        let toType = String(describing: type(of: viewController))
        let eventLog = EventLog(
            category: "Navigation",
            eventType: "push",
            detail: "UINavigationController from=\(fromType) to=\(toType) animated=\(animated)"
        )
        EventLogger.shared.log(eventLog)
        hs_instrumented_pushViewController(viewController, animated: animated)
    }

    @objc func hs_instrumented_popViewController(animated: Bool) -> UIViewController? {
        let fromType = String(describing: type(of: topViewController ?? UIViewController()))
        let eventLog = EventLog(
            category: "Navigation",
            eventType: "pop",
            detail: "UINavigationController from=\(fromType) animated=\(animated)"
        )
        EventLogger.shared.log(eventLog)
        return hs_instrumented_popViewController(animated: animated)
    }

    @objc func hs_instrumented_popToRootViewController(animated: Bool) -> [UIViewController]? {
        let fromType = String(describing: type(of: topViewController ?? UIViewController()))
        let eventLog = EventLog(
            category: "Navigation",
            eventType: "popToRoot",
            detail: "UINavigationController from=\(fromType) animated=\(animated)"
        )
        EventLogger.shared.log(eventLog)
        return hs_instrumented_popToRootViewController(animated: animated)
    }

    @objc func hs_instrumented_popToViewController(
        _ viewController: UIViewController,
        animated: Bool
    ) -> [UIViewController]? {
        let fromType = String(describing: type(of: topViewController ?? UIViewController()))
        let toType = String(describing: type(of: viewController))
        let eventLog = EventLog(
            category: "Navigation",
            eventType: "popTo",
            detail: "UINavigationController from=\(fromType) to=\(toType) animated=\(animated)"
        )
        EventLogger.shared.log(eventLog)
        return hs_instrumented_popToViewController(viewController, animated: animated)
    }
}
