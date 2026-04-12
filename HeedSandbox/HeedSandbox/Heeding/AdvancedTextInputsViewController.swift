//
//  AdvancedTextInputsViewController.swift
//  HeedSandbox
//
//  Created by Codex on 12.04.2026.
//

import UIKit

final class AdvancedTextInputsViewController: UIViewController, UISearchBarDelegate {
    
    private let searchBar: UISearchBar = {
        let view = UISearchBar()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.placeholder = "Search events"
        view.showsCancelButton = true
        return view
    }()
    
    private let textView: UITextView = {
        let view = UITextView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = .systemFont(ofSize: 16)
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemGray4.cgColor
        view.layer.cornerRadius = 12
        view.text = "Type here to test UITextView instrumentation."
        return view
    }()
    
    private let hintLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 14)
        label.text = "Try focus, typing, Search, and Cancel to see UISearchBar and UITextView events."
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Search & Text View"
        view.backgroundColor = .systemBackground
        
        searchBar.delegate = self
        
        view.addSubview(searchBar)
        view.addSubview(hintLabel)
        view.addSubview(textView)
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            
            hintLabel.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 16),
            hintLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            hintLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            textView.topAnchor.constraint(equalTo: hintLabel.bottomAnchor, constant: 16),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            textView.heightAnchor.constraint(equalToConstant: 220)
        ])
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        searchBar.resignFirstResponder()
    }
}
