//
//  LifecycleAndErrorsViewController.swift
//  HeedSandbox
//
//  Created by Codex on 12.04.2026.
//

import UIKit
import HeedInstrument

private enum DemoNonFatalError: LocalizedError {
    case simulated
    
    var errorDescription: String? {
        "Simulated non-fatal error from HeedSandbox"
    }
}

final class LifecycleAndErrorsViewController: UIViewController {
    
    private let breadcrumbButton = LifecycleAndErrorsViewController.makeButton(title: "Leave Breadcrumb")
    private let nonFatalButton = LifecycleAndErrorsViewController.makeButton(title: "Record Non-Fatal Error")
    private let crashButton = LifecycleAndErrorsViewController.makeButton(title: "Crash with NSException")
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 14)
        label.text = "Open this screen, then background/foreground the app to see lifecycle events. Use the buttons below to test breadcrumbs, non-fatal errors, and uncaught exception logging."
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Lifecycle & Errors"
        view.backgroundColor = .systemBackground
        
        breadcrumbButton.addTarget(self, action: #selector(recordBreadcrumb), for: .touchUpInside)
        nonFatalButton.addTarget(self, action: #selector(recordNonFatal), for: .touchUpInside)
        crashButton.addTarget(self, action: #selector(triggerCrash), for: .touchUpInside)
        
        let stack = UIStackView(arrangedSubviews: [breadcrumbButton, nonFatalButton, crashButton])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 14
        
        view.addSubview(infoLabel)
        view.addSubview(stack)
        
        NSLayoutConstraint.activate([
            infoLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            infoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            infoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            stack.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 24),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    @objc private func recordBreadcrumb() {
        HeedInstrument.leaveBreadcrumb("LifecycleAndErrorsViewController button tapped")
    }
    
    @objc private func recordNonFatal() {
        HeedInstrument.record(error: DemoNonFatalError.simulated, metadata: ["screen": "LifecycleAndErrors"])
    }
    
    @objc private func triggerCrash() {
        HeedInstrument.leaveBreadcrumb("About to raise NSException from sandbox")
        NSException(name: .internalInconsistencyException, reason: "Sandbox crash test", userInfo: nil).raise()
    }
    
    private static func makeButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .filled()
        button.configuration?.title = title
        return button
    }
}
