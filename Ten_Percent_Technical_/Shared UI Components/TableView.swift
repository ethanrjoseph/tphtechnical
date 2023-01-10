//
//  TableView.swift
//  Ten_Percent_Technical_
//
//  Created by Ethan Joseph on 1/9/23.
//

import Foundation
import UIKit

class TableView: UITableView {

    init() {
        super.init(frame: .zero, style: .plain)
        self.separatorStyle = .none
        self.estimatedRowHeight = 80
        self.allowsSelection = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var rowHeight: CGFloat {
        get {
            return 80
        }
        set {
            guard self.rowHeight != newValue else { return }
            self.rowHeight = newValue
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }
}

class TableViewCell: UITableViewCell {
    func configure(for item: Any) {}
}

//TODO: Ideally i would make this generic to work with any type of section / row data model, but i dont have time right now :( 
class TableViewManager<T: TableViewCell>: NSObject, UITableViewDelegate, UITableViewDataSource {

    private let tableView: TableView
    //var rows: [Any] = []
    var sections: [[Any]] = []
    
    var selectionHandler: ((IndexPath) -> Void)?

    init(tableView: TableView) {
        self.tableView = tableView
        self.tableView.register(T.self, forCellReuseIdentifier: T.description())
        self.tableView.reloadData()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rowsForSection = self.sections[section]
        return rowsForSection.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: T.description(), for: indexPath) as! T
        let item = self.sections[indexPath.section][indexPath.row]
        cell.configure(for: item)
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.tableView.rowHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectionHandler?(indexPath)
    }
}
