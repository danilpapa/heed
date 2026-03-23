//
//  UIGestureRecognizer+.swift
//  HeedInstrument
//
//  Created by setuper on 23.03.2026.
//

import UIKit
import ObjectiveC.runtime

private enum HeedGestureContext {
    static let didWireKey = "heed.gesture.didWire"
    static let lastStateKey = "heed.gesture.lastState"
    static let lastLogKey = "heed.gesture.lastLog"
    static let minInterval: CFTimeInterval = 0.05
}

extension UIGestureRecognizer {

    @objc func hs_instrumented_addTarget(_ target: Any, action: Selector) {
        hs_instrumented_addTarget(target, action: action)
        hs_wireGestureLoggerIfNeeded()
    }

    @objc func hs_instrumented_initWithTarget(_ target: Any?, action: Selector?) -> UIGestureRecognizer {
        let recognizer = hs_instrumented_initWithTarget(target, action: action)
        recognizer.hs_wireGestureLoggerIfNeeded()
        return recognizer
    }

    private func hs_wireGestureLoggerIfNeeded() {
        let didWire = (objc_getAssociatedObject(self, HeedGestureContext.didWireKey) as? Bool) ?? false
        guard !didWire else { return }
        objc_setAssociatedObject(self, HeedGestureContext.didWireKey, true, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        addTarget(self, action: #selector(hs_instrumented_handleGesture(_:)))
    }

    @objc private func hs_instrumented_handleGesture(_ gesture: UIGestureRecognizer) {
        let now = CFAbsoluteTimeGetCurrent()
        let lastLog = (objc_getAssociatedObject(self, HeedGestureContext.lastLogKey) as? Double) ?? 0
        if now - lastLog < HeedGestureContext.minInterval {
            return
        }

        let typeName = String(describing: type(of: gesture))
        let stateName = hs_gestureStateName(gesture.state)

        let lastStateRaw = (objc_getAssociatedObject(self, HeedGestureContext.lastStateKey) as? Int) ?? -1
        if lastStateRaw == gesture.state.rawValue {
            return
        }

        objc_setAssociatedObject(self, HeedGestureContext.lastLogKey, now, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(self, HeedGestureContext.lastStateKey, gesture.state.rawValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        let eventLog = EventLog(
            category: "UI",
            eventType: "gesture",
            detail: "UIGestureRecognizer type=\(typeName) state=\(stateName)"
        )
        EventLogger.shared.log(eventLog)
    }

    private func hs_gestureStateName(_ state: UIGestureRecognizer.State) -> String {
        switch state {
        case .possible: return "possible"
        case .began: return "began"
        case .changed: return "changed"
        case .ended: return "ended"
        case .cancelled: return "cancelled"
        case .failed: return "failed"
        @unknown default: return "unknown"
        }
    }
}
