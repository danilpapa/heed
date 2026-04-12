//
//  File.swift
//  HeedInstrument
//
//  Created by setuper on 08.03.2026.
//

import Foundation

public final class HeedInstrument {
    
    public static func start() {
        Heed.invoke {
            UIButtonSwizzling.self
            UIControlAddActionSwizzling.self
            UITextFieldSwizzling.self
            UIGestureRecognizerSwizzling.self
            UITableViewSwizzling.self
            UIViewControllerSwizzling.self
            UINavigationControllerSwizzling.self
            UIAlertControllerSwizzling.self
            URLSessionSwizzling.self
        }

        KeyboardObserver.shared.start()
        AppLifecycleObserver.shared.start()
    }
    
    public static func leaveBreadcrumb(_ message: String) {
        EventLogger.shared.log(
            EventLog(
                category: "Reliability",
                eventType: "breadcrumb",
                detail: message
            )
        )
    }
    
    public static func record(error: Error, metadata: [String: String] = [:]) {
        let metadataText = metadata
            .sorted { $0.key < $1.key }
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: " ")
        let detail = metadataText.isEmpty
            ? String(describing: error)
            : "\(error) \(metadataText)"
        
        EventLogger.shared.log(
            EventLog(
                category: "Reliability",
                eventType: "nonFatalError",
                detail: detail
            )
        )
    }
}
