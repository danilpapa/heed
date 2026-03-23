//
//  UITextField+.swift
//  HeedInstrument
//
//  Created by setuper on 23.03.2026.
//

import UIKit
import ObjectiveC.runtime

private enum HeedTextFieldContext {
    static let didWireKey = "heed.textField.didWire"
}

extension UITextField {

    @objc func hs_instrumented_didMoveToWindow() {
        hs_instrumented_didMoveToWindow()

        guard window != nil else { return }
        let didWire = (objc_getAssociatedObject(self, HeedTextFieldContext.didWireKey) as? Bool) ?? false
        guard !didWire else { return }

        objc_setAssociatedObject(
            self,
            HeedTextFieldContext.didWireKey,
            true,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )

        addTarget(self, action: #selector(hs_instrumented_editingDidBegin(_:)), for: .editingDidBegin)
        addTarget(self, action: #selector(hs_instrumented_editingChanged(_:)), for: .editingChanged)
        addTarget(self, action: #selector(hs_instrumented_editingDidEnd(_:)), for: .editingDidEnd)
        addTarget(self, action: #selector(hs_instrumented_editingDidEndOnExit(_:)), for: .editingDidEndOnExit)
    }

    @objc func hs_instrumented_editingDidBegin(_ sender: UITextField) {
        let count = sender.text?.count ?? 0
        let eventLog = EventLog(
            debug_detail: "UITextField editingDidBegin text.count=\(count)"
        )
        EventLogger.shared.log(eventLog)
    }

    @objc func hs_instrumented_editingChanged(_ sender: UITextField) {
        let count = sender.text?.count ?? 0
        let eventLog = EventLog(
            debug_detail: "UITextField editingChanged text.count=\(count)"
        )
        EventLogger.shared.log(eventLog)
    }

    @objc func hs_instrumented_editingDidEnd(_ sender: UITextField) {
        let count = sender.text?.count ?? 0
        let eventLog = EventLog(
            debug_detail: "UITextField editingDidEnd text.count=\(count)"
        )
        EventLogger.shared.log(eventLog)
    }

    @objc func hs_instrumented_editingDidEndOnExit(_ sender: UITextField) {
        let count = sender.text?.count ?? 0
        let eventLog = EventLog(
            debug_detail: "UITextField editingDidEndOnExit text.count=\(count)"
        )
        EventLogger.shared.log(eventLog)
    }
}
