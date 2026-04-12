//
//  ScrollViewViewController.swift
//  HeedSandbox
//
//  Created by setuper on 23.03.2026.
//

import UIKit

final class ScrollViewViewController: UIViewController, UIScrollViewDelegate {

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Scroll"
        view.backgroundColor = .white

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.delegate = self
        view.addSubview(scrollView)

        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 12
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])

        for i in 1...30 {
            let label = UILabel()
            label.text = "Row \(i)"
            label.backgroundColor = i % 2 == 0 ? .systemGray5 : .systemGray6
            label.textAlignment = .center
            label.heightAnchor.constraint(equalToConstant: 48).isActive = true
            contentStack.addArrangedSubview(label)
        }
    }
}
