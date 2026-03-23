//
//  UIGestureRecognizer+.swift
//  HeedInstrument
//
//  Created by setuper on 23.03.2026.
//

import UIKit
import ObjectiveC.runtime

private enum HeedGestureContext {
    nonisolated(unsafe) static var didWireKey: UInt8 = 0
    nonisolated(unsafe) static var didLogChangedKey: UInt8 = 0
    nonisolated(unsafe) static var didLogEndedKey: UInt8 = 0
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
        let didWire = (objc_getAssociatedObject(self, &HeedGestureContext.didWireKey) as? Bool) ?? false
        guard !didWire else { return }
        objc_setAssociatedObject(self, &HeedGestureContext.didWireKey, true, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        addTarget(self, action: #selector(hs_instrumented_handleGesture(_:)))
    }
    
    @objc private func hs_instrumented_handleGesture(_ gesture: UIGestureRecognizer) {
        switch gesture.state {
        case .began:
            objc_setAssociatedObject(self, &HeedGestureContext.didLogChangedKey, false, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            objc_setAssociatedObject(self, &HeedGestureContext.didLogEndedKey, false, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return
        case .changed:
            let didLogChanged = (objc_getAssociatedObject(self, &HeedGestureContext.didLogChangedKey) as? Bool) ?? false
            if didLogChanged { return }
            objc_setAssociatedObject(self, &HeedGestureContext.didLogChangedKey, true, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        case .ended, .cancelled, .failed:
            let didLogEnded = (objc_getAssociatedObject(self, &HeedGestureContext.didLogEndedKey) as? Bool) ?? false
            if didLogEnded { return }
            objc_setAssociatedObject(self, &HeedGestureContext.didLogEndedKey, true, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        default:
            return
        }

        let typeName = String(describing: type(of: gesture))
        let stateName = hs_gestureStateName(gesture.state)
        
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
