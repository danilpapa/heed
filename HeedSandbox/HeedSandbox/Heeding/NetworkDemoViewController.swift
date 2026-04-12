//
//  NetworkDemoViewController.swift
//  HeedSandbox
//
//  Created by setuper on 25.03.2026.
//

import UIKit

final class NetworkDemoViewController: UIViewController {

    private let session = URLSession(configuration: .default)
    private lazy var timeoutSession: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 1
        config.timeoutIntervalForResource = 1
        return URLSession(configuration: config)
    }()
    private var cancellableTask: URLSessionDataTask?

    private let statusButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("API status", for: .normal)
        return button
    }()

    private let oficialButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Dolar oficial", for: .normal)
        return button
    }()

    private let blueButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Dolar blue", for: .normal)
        return button
    }()
    
    private let failButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("HTTP fail", for: .normal)
        return button
    }()
    
    private let timeoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Timeout", for: .normal)
        return button
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Cancel request", for: .normal)
        return button
    }()

    private let outputLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 14)
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Network"
        view.backgroundColor = .white

        statusButton.addTarget(self, action: #selector(fetchStatus), for: .touchUpInside)
        oficialButton.addTarget(self, action: #selector(fetchOficial), for: .touchUpInside)
        blueButton.addTarget(self, action: #selector(fetchBlue), for: .touchUpInside)
        failButton.addTarget(self, action: #selector(fetchFail), for: .touchUpInside)
        timeoutButton.addTarget(self, action: #selector(fetchTimeout), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(fetchCancelable), for: .touchUpInside)

        let buttonStack = UIStackView(arrangedSubviews: [statusButton, oficialButton, blueButton, failButton, timeoutButton, cancelButton])
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.axis = .vertical
        buttonStack.spacing = 12
        buttonStack.alignment = .leading

        view.addSubview(buttonStack)
        view.addSubview(outputLabel)

        NSLayoutConstraint.activate([
            buttonStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            buttonStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonStack.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20),

            outputLabel.topAnchor.constraint(equalTo: buttonStack.bottomAnchor, constant: 24),
            outputLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            outputLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    @objc private func fetchStatus() {
        request(urlString: "https://dolarapi.com/v1/estado")
    }

    @objc private func fetchOficial() {
        request(urlString: "https://dolarapi.com/v1/dolares/oficial")
    }

    @objc private func fetchBlue() {
        request(urlString: "https://dolarapi.com/v1/dolares/blue")
    }
    
    @objc private func fetchFail() {
        request(urlString: "https://httpstat.us/503")
    }
    
    @objc private func fetchTimeout() {
        request(urlString: "https://httpstat.us/200?sleep=5000", session: timeoutSession)
    }
    
    @objc private func fetchCancelable() {
        guard let url = URL(string: "https://httpstat.us/200?sleep=5000") else { return }
        let task = session.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.renderResult(data: data, error: error)
            }
        }
        cancellableTask = task
        task.resume()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.cancellableTask?.cancel()
            self?.outputLabel.text = "Cancelled"
            self?.cancellableTask = nil
        }
    }

    private func request(urlString: String, session: URLSession? = nil) {
        guard let url = URL(string: urlString) else { return }
        let task = (session ?? self.session).dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.renderResult(data: data, error: error)
            }
        }
        task.resume()
    }
    
    private func renderResult(data: Data?, error: Error?) {
        if let error {
            outputLabel.text = "Error: \(error)"
            return
        }
        if let data, let text = String(data: data, encoding: .utf8) {
            outputLabel.text = text
        } else {
            outputLabel.text = "No data"
        }
    }
}
