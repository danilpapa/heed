//
//  DemoListViewController.swift
//  HeedSandbox
//
//  Created by setuper on 23.03.2026.
//

import UIKit

final class DemoListViewController: UIViewController {

    private struct DemoItem {
        let title: String
        let makeViewController: () -> UIViewController
    }

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let items: [DemoItem] = [
        DemoItem(title: "Buttons") { ButtonsViewController() },
        DemoItem(title: "Text Fields") { TextFieldsViewController() },
        DemoItem(title: "Gestures") { GesturesViewController() },
        DemoItem(title: "Scroll") { ScrollViewViewController() },
        DemoItem(title: "Navigation Stack") { NavigationStackViewController() }
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "HeedSandbox"
        view.backgroundColor = .systemBackground

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DemoCell")
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension DemoListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DemoCell", for: indexPath)
        cell.textLabel?.text = items[indexPath.row].title
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}

extension DemoListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = items[indexPath.row].makeViewController()
        vc.title = items[indexPath.row].title
        navigationController?.pushViewController(vc, animated: true)
    }
}
