//
//  ViewController.swift
//  Ten_Percent_Technical_
//
//  Created by Ethan Joseph on 1/9/23.
//

import UIKit

class TopicsViewController: UIViewController {

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
        self.manager.rows = store.topics
    }
}

class TopicsTableView: UITableView {

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


class TopicsTableViewManager: NSObject, UITableViewDelegate, UITableViewDataSource {

    private let tableView: TopicsTableView
    var rows: [Topics.Topic] = []
    var sections: [Int] = [1]

    init(tableView: TopicsTableView) {
        self.tableView = tableView

        self.tableView.register(TopicsCell.self, forCellReuseIdentifier: "TopicsCell")
        self.tableView.reloadData()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TopicsCell", for: indexPath) as! TopicsCell

        let itemType = self.rows[indexPath.row]
        
        cell.configure(for: itemType)
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.tableView.rowHeight
    }
}

class TopicsCell: UITableViewCell {

    var containerView = UIView()
    var colorStrip = UIView()
    var titleLabel = UILabel()
    var meditationsLabel = UILabel()
    
    required init?(coder: NSCoder) {
       fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
       super.init(style: style, reuseIdentifier: "cell")
        
        self.containerView.layer.borderWidth = 1.0
        self.containerView.layer.borderColor = UIColor.lightGray.cgColor
        self.containerView.layer.cornerRadius = 3.0
        
        
        
        self.addSubview(self.containerView)
        
        self.containerView.addSubview(self.colorStrip)
        self.containerView.addSubview(self.titleLabel)
        self.containerView.addSubview(self.meditationsLabel)
    }

    func configure(for topic: Topics.Topic) {
        
        self.colorStrip.backgroundColor = UIColor(hexString: topic.color)
    
        self.titleLabel.text = topic.title
        self.titleLabel.textColor = .black
        
        self.meditationsLabel.text = "\(topic.meditations.count) meditations"
        self.meditationsLabel.textColor = .gray
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.titleLabel.text = nil
        self.meditationsLabel.text = nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.containerView.pin(.top)
        self.containerView.pin(.left, padding: 15)
        self.containerView.expand(.right, padding: 15)
        self.containerView.expand(.bottom, padding: 10)
        
        self.colorStrip.expandToSuperviewHeight()
        self.colorStrip.pin(.left)
        self.colorStrip.width = 15

        self.titleLabel.size = CGSize(width: self.contentView.width, height: 30)
        self.titleLabel.pin(.top, padding: 10)
        self.titleLabel.pin(.left, padding: 30)

        self.meditationsLabel.numberOfLines = 0
        self.meditationsLabel.width = self.contentView.width - 120
        self.meditationsLabel.sizeToFit()

        self.meditationsLabel.match(.top, to: .bottom, of: self.titleLabel)
        self.meditationsLabel.match(.left, to: .left, of: self.titleLabel)
    }
}
