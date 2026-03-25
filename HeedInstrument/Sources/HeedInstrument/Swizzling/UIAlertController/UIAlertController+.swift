//
//  UIAlertController+.swift
//  HeedInstrument
//
//  Created by setuper on 25.03.2026.
//

import UIKit
import ObjectiveC.runtime

private enum HeedAlertContext {
    nonisolated(unsafe) static var didWrapKey: UInt8 = 0
}

extension UIAlertController {

    @objc func hs_instrumented_addAction(_ action: UIAlertAction) {
        hs_instrumented_addAction(hs_wrapActionIfNeeded(action))
    }

    private func hs_wrapActionIfNeeded(_ action: UIAlertAction) -> UIAlertAction {
        let didWrap = (objc_getAssociatedObject(action, &HeedAlertContext.didWrapKey) as? Bool) ?? false
        if didWrap { return action }

        let title = action.title ?? ""
        let style = hs_alertStyleName(action.style)
        let originalHandler = action.value(forKey: "handler") as? ((UIAlertAction) -> Void)

        let wrappedHandler: (UIAlertAction) -> Void = { act in
            let eventLog = EventLog(
                category: "UI",
                eventType: "alertAction",
                detail: "UIAlertAction title=\(title) style=\(style)"
            )
            EventLogger.shared.log(eventLog)
            originalHandler?(act)
        }

        let wrapped = UIAlertAction(title: title, style: action.style, handler: wrappedHandler)
        objc_setAssociatedObject(wrapped, &HeedAlertContext.didWrapKey, true, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return wrapped
    }

    private func hs_alertStyleName(_ style: UIAlertAction.Style) -> String {
        switch style {
        case .default: return "default"
        case .cancel: return "cancel"
        case .destructive: return "destructive"
        @unknown default: return "unknown"
        }
    }
}
