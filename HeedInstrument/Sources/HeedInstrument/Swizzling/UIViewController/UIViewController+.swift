//
//  UIViewController+.swift
//  HeedInstrument
//
//  Created by setuper on 25.03.2026.
//

import UIKit

extension UIViewController {

    @objc func hs_instrumented_viewDidLoad() {
        logLifecycle("viewDidLoad")
        hs_instrumented_viewDidLoad()
    }

    @objc func hs_instrumented_viewWillAppear(_ animated: Bool) {
        logLifecycle("viewWillAppear")
        hs_instrumented_viewWillAppear(animated)
    }

    @objc func hs_instrumented_viewDidAppear(_ animated: Bool) {
        logLifecycle("viewDidAppear")
        hs_instrumented_viewDidAppear(animated)
    }

    @objc func hs_instrumented_viewWillDisappear(_ animated: Bool) {
        logLifecycle("viewWillDisappear")
        hs_instrumented_viewWillDisappear(animated)
    }

    @objc func hs_instrumented_viewDidDisappear(_ animated: Bool) {
        logLifecycle("viewDidDisappear")
        hs_instrumented_viewDidDisappear(animated)
    }

    private func logLifecycle(_ name: String) {
        let typeName = String(describing: type(of: self))
        let eventLog = EventLog(
            category: "Navigation",
            eventType: name,
            detail: "UIViewController type=\(typeName)"
        )
        EventLogger.shared.log(eventLog)
    }

    @objc func hs_instrumented_present(
        _ viewControllerToPresent: UIViewController,
        animated: Bool,
        completion: (() -> Void)?
    ) {
        let fromType = String(describing: type(of: self))
        let toType = String(describing: type(of: viewControllerToPresent))
        if let alert = viewControllerToPresent as? UIAlertController {
            let style = alert.preferredStyle == .alert ? "alert" : "actionSheet"
            let title = alert.title ?? ""
            let message = alert.message ?? ""
            let eventLog = EventLog(
                category: "UI",
                eventType: "alertPresent",
                detail: "UIAlertController style=\(style) title=\(title) message=\(message)"
            )
            EventLogger.shared.log(eventLog)
        }
        let eventLog = EventLog(
            category: "Navigation",
            eventType: "present",
            detail: "UIViewController from=\(fromType) to=\(toType) animated=\(animated)"
        )
        EventLogger.shared.log(eventLog)
        hs_instrumented_present(viewControllerToPresent, animated: animated, completion: completion)
    }
}
