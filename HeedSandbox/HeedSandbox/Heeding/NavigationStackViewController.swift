//
//  NavigationStackViewController.swift
//  HeedSandbox
//
//  Created by setuper on 25.03.2026.
//

import UIKit

final class NavigationStackViewController: UIViewController {

    private let pushButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Push Next", for: .normal)
        return button
    }()

    private let presentButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Present Modal", for: .normal)
        return button
    }()

    private let popButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Pop", for: .normal)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Navigation Stack"
        view.backgroundColor = .white

        pushButton.addTarget(self, action: #selector(pushNext), for: .touchUpInside)
        presentButton.addTarget(self, action: #selector(presentModal), for: .touchUpInside)
        popButton.addTarget(self, action: #selector(popSelf), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [pushButton, presentButton, popButton])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .center

        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    @objc private func pushNext() {
        let next = NavigationStackViewController()
        navigationController?.pushViewController(next, animated: true)
    }

    @objc private func presentModal() {
        let modal = ModalTestViewController()
        let nav = UINavigationController(rootViewController: modal)
        present(nav, animated: true, completion: nil)
    }

    @objc private func popSelf() {
        navigationController?.popViewController(animated: true)
    }
}
