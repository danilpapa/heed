//
//  KeyboardObserver.swift
//  HeedInstrument
//
//  Created by setuper on 24.03.2026.
//

import UIKit

final class KeyboardObserver: NSObject {

    nonisolated(unsafe) static let shared = KeyboardObserver()
    private var isStarted = false

    func start() {
        guard !isStarted else { return }
        isStarted = true

        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(handleWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: #selector(handleWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        center.addObserver(self, selector: #selector(handleWillChangeFrame(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    @objc private func handleWillShow(_ note: Notification) {
        log(note, eventType: "keyboardWillShow")
    }

    @objc private func handleWillHide(_ note: Notification) {
        log(note, eventType: "keyboardWillHide")
    }

    @objc private func handleWillChangeFrame(_ note: Notification) {
        log(note, eventType: "keyboardWillChangeFrame")
    }

    private func log(_ note: Notification, eventType: String) {
        let info = note.userInfo
        let duration = (info?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double) ?? 0
        let curveRaw = (info?[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int) ?? 0
        let endFrame = (info?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect) ?? .zero
        let height = Int(endFrame.height.rounded())

        let eventLog = EventLog(
            category: "UI",
            eventType: eventType,
            duration: duration,
            detail: "keyboard height=\(height) curve=\(curveRaw)"
        )
        EventLogger.shared.log(eventLog)
    }
}
