//
//  ViewController.swift
//  HeedSandbox
//
//  Created by setuper on 07.03.2026.
//

import UIKit

class ViewController: UIViewController {
    
    private lazy var button: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Tap me", for: .normal)
        button.addTarget(
            self,
            action: #selector(tap),
            for: .touchUpInside
        )
        button.setTitleColor(.green, for: .normal)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(button)
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            button.widthAnchor.constraint(equalToConstant: 100),
            button.heightAnchor.constraint(equalToConstant: 50),
        ])
    }
    
    @objc
    func tap() {
        print("Tap")
    }
}
