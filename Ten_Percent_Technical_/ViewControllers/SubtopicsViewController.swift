//
//  SubtopicsViewController.swift
//  Ten_Percent_Technical_
//
//  Created by Ethan Joseph on 1/9/23.
//

import Foundation
import UIKit

class SubtopicsViewController: UIViewController {

    weak var coordinator: MainCoordinator?

    lazy var tableView = TopicsTableView()
    lazy var manager = TopicsTableViewManager(tableView: tableView)
    
    override func loadView() {
        self.view = self.tableView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        
        self.tableView.delegate = self.manager
        self.tableView.dataSource = self.manager
        
        self.title = "Topics"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateTableView()
    }
    
    private func updateTableView() {
        var featuredTopics = store.topics.filter{ $0.featured }
            featuredTopics.sort{ $0.position < $1.position }
        self.manager.rows = featuredTopics
    }
}
