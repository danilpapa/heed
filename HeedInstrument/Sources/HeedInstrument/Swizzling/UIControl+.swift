//
//  File.swift
//  HeedInstrument
//
//  Created by setuper on 07.03.2026.
//

import UIKit

extension UIControl {
    
    @objc func hs_instrumented_sendAction (
        _ action: Selector,
        to target: Any?,
        for event: UIEvent?
    ) {
        let eventLog = EventLog(debug_detail: String(describing: self))
        
        EventLogger.shared.log(eventLog)
        
        hs_instrumented_sendAction(
            action,
            to: target,
            for: event
        )
    }
}
