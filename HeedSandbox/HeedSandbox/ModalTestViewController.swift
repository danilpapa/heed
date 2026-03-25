//
//  ModalTestViewController.swift
//  HeedSandbox
//
//  Created by setuper on 25.03.2026.
//

import UIKit

final class ModalTestViewController: UIViewController {

    private let dismissButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Dismiss", for: .normal)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Modal"
        view.backgroundColor = .white

        dismissButton.addTarget(self, action: #selector(dismissSelf), for: .touchUpInside)
        view.addSubview(dismissButton)

        NSLayoutConstraint.activate([
            dismissButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dismissButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    @objc private func dismissSelf() {
        dismiss(animated: true, completion: nil)
    }
}
