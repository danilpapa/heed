//
//  AppLifecycleObserver.swift
//  HeedInstrument
//
//  Created by Codex on 12.04.2026.
//

import UIKit

final class AppLifecycleObserver: NSObject {
    
    nonisolated(unsafe) static let shared = AppLifecycleObserver()
    
    private let startDate = Date()
    private var isStarted = false
    private var didLogFirstScreenRender = false
    
    func start() {
        guard !isStarted else { return }
        isStarted = true
        
        let center = NotificationCenter.default
        center.addObserver(
            self,
            selector: #selector(handleDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        center.addObserver(
            self,
            selector: #selector(handleWillResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
        center.addObserver(
            self,
            selector: #selector(handleWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
        center.addObserver(
            self,
            selector: #selector(handleDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
    }
    
    func recordFirstScreenRenderIfNeeded(screenName: String, at date: Date) {
        guard !didLogFirstScreenRender else { return }
        didLogFirstScreenRender = true
        
        EventLogger.shared.log(
            EventLog(
                timestamp: date,
                category: "Performance",
                eventType: "firstScreenRender",
                duration: date.timeIntervalSince(startDate),
                detail: "screen=\(screenName)"
            )
        )
    }
    
    @objc private func handleDidBecomeActive() {
        logAppEvent("didBecomeActive")
    }
    
    @objc private func handleWillResignActive() {
        logAppEvent("willResignActive")
    }
    
    @objc private func handleWillEnterForeground() {
        logAppEvent("willEnterForeground")
    }
    
    @objc private func handleDidEnterBackground() {
        logAppEvent("didEnterBackground")
    }
    
    private func logAppEvent(_ name: String) {
        EventLogger.shared.log(
            EventLog(
                category: "App",
                eventType: name,
                detail: "UIApplication lifecycle"
            )
        )
    }
}
