//
//  ButtonsViewController.swift
//  HeedSandbox
//
//  Created by setuper on 07.03.2026.
//

import UIKit

final class ButtonsViewController: UIViewController {
    
    private lazy var selectorButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Tap me selector", for: .normal)
        button.addTarget(
            self,
            action: #selector(tap),
            for: .touchUpInside
        )
        button.setTitleColor(.green, for: .normal)
        button.backgroundColor = .red
        return button
    }()
    
    private lazy var actionButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Tap me action", for: .normal)
        button.addAction(UIAction { _ in
            print("Tap action")
        }, for: .touchUpInside)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .blue
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Buttons"
        view.backgroundColor = .white
        view.addSubview(selectorButton)
        NSLayoutConstraint.activate([
            selectorButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            selectorButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            selectorButton.widthAnchor.constraint(equalToConstant: 100),
            selectorButton.heightAnchor.constraint(equalToConstant: 50),
        ])
        
        view.addSubview(actionButton)
        NSLayoutConstraint.activate([
            actionButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            actionButton.topAnchor.constraint(equalTo: selectorButton.bottomAnchor),
            actionButton.widthAnchor.constraint(equalToConstant: 100),
            actionButton.heightAnchor.constraint(equalToConstant: 50),
        ])
    }
    
    @objc func tap() {
        print("Tap")
    }
}
