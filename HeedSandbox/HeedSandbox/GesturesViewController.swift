//
//  GesturesViewController.swift
//  HeedSandbox
//
//  Created by setuper on 23.03.2026.
//

import UIKit

final class GesturesViewController: UIViewController {

    private let tapBox = UIView()
    private let panBox = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Gestures"
        view.backgroundColor = .white

        tapBox.translatesAutoresizingMaskIntoConstraints = false
        tapBox.backgroundColor = .systemGreen
        tapBox.layer.cornerRadius = 12

        panBox.translatesAutoresizingMaskIntoConstraints = false
        panBox.backgroundColor = .systemOrange
        panBox.layer.cornerRadius = 12

        view.addSubview(tapBox)
        view.addSubview(panBox)

        NSLayoutConstraint.activate([
            tapBox.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tapBox.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -80),
            tapBox.widthAnchor.constraint(equalToConstant: 200),
            tapBox.heightAnchor.constraint(equalToConstant: 120),

            panBox.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            panBox.topAnchor.constraint(equalTo: tapBox.bottomAnchor, constant: 24),
            panBox.widthAnchor.constraint(equalToConstant: 200),
            panBox.heightAnchor.constraint(equalToConstant: 120),
        ])

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tapBox.addGestureRecognizer(tap)

        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        panBox.addGestureRecognizer(pan)
    }

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        if gesture.state == .ended {
            print("Tap box")
        }
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        if gesture.state == .ended {
            print("Pan box")
        }
    }
}
