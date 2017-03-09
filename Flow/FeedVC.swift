//
//  FeedVC.swift
//  Flow
//
//  Created by Garric Nahapetian on 1/15/17.
//  Copyright © 2017 Garric Nahapetian. All rights reserved.
//

import UIKit

final class FeedVC: UIViewController {
    fileprivate let viewModel: FeedVM
    private let tableView = UITableView(frame: CGRect.zero, style: .plain)

    init(viewModel: FeedVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = tableView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }

    private func configure() {
        tableView.estimatedRowHeight = UIScreen.main.bounds.width
        tableView.rowHeight = UIScreen.main.bounds.width
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(
            FeedCell.self,
            forCellReuseIdentifier: FeedCell.reuseID
        )
    }
}

extension FeedVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dequeuedCell = tableView.dequeueReusableCell(withIdentifier: FeedCell.reuseID)
        return viewModel.cellForRow(at: indexPath, from: dequeuedCell)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIScreen.main.bounds.width
    }
}

extension FeedVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        viewModel.didSelectRow(at: indexPath)
    }
}
