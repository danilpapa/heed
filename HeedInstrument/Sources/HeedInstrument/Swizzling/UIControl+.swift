//
//  File.swift
//  HeedInstrument
//
//  Created by setuper on 07.03.2026.
//

import UIKit
import ObjectiveC.runtime

private enum HeedUIControlActionContext {
    static let loggedEventsKey = "heed.loggedControlEvents"
}

extension UIControl {

    @objc(hs_instrumented_addAction:forControlEvents:)
    func hs_instrumented_addAction(_ action: UIAction, for controlEvents: UIControl.Event) {
        hs_instrumented_addAction(action, for: controlEvents)

        let existing = (objc_getAssociatedObject(self, HeedUIControlActionContext.loggedEventsKey) as? UInt) ?? 0
        let newEvents = controlEvents.rawValue & ~existing
        guard newEvents != 0 else { return }

        let updated = existing | newEvents
        objc_setAssociatedObject(
            self,
            HeedUIControlActionContext.loggedEventsKey,
            updated,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )

        let eventsToLog = UIControl.Event(rawValue: newEvents)
        addTarget(self, action: #selector(hs_instrumented_logActionEvent(_:)), for: eventsToLog)
    }

    @objc func hs_instrumented_logActionEvent(_ sender: UIControl) {
        let eventLog = EventLog(
            debug_detail: "UIAction event control=\(type(of: sender))"
        )
        EventLogger.shared.log(eventLog)
    }
    
    @objc func hs_instrumented_sendAction (
        _ action: Selector,
        to target: Any?,
        for event: UIEvent?
    ) {
        if action == #selector(hs_instrumented_logActionEvent(_:)) {
            hs_instrumented_sendAction(action, to: target, for: event)
            return
        }

        if let target, target is UIAction {
            hs_instrumented_sendAction(
                action,
                to: target,
                for: event
            )
            return
        }

        let eventLog = EventLog(debug_detail: String(describing: self))
        
        EventLogger.shared.log(eventLog)
        
        hs_instrumented_sendAction(
            action,
            to: target,
            for: event
        )
    }
}
