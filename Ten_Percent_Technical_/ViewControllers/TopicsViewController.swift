//
//  ViewController.swift
//  Ten_Percent_Technical_
//
//  Created by Ethan Joseph on 1/9/23.
//

import UIKit

protocol TopicsViewControllerDelegate: AnyObject {
    func topicsViewController(didSelect: Topics.Topic, _ controller: TopicsViewController)
}

class TopicsViewController: UIViewController {
    
    init(delegate: TopicsViewControllerDelegate) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    unowned var delegate: TopicsViewControllerDelegate

    private lazy var tableView = TableView()
    private lazy var manager = TableViewManager<TopicsCell>(tableView: tableView)
    private var featuredTopics: [Topics.Topic] = []
    
    override func loadView() {
        self.view = self.tableView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        
        self.tableView.delegate = self.manager
        self.tableView.dataSource = self.manager
        self.manager.selectionHandler = { [unowned self] indexPath  in
            // get the corresponding topic
            let topic = featuredTopics[indexPath.row]
            self.delegate.topicsViewController(didSelect: topic, self)
        }
        
        self.title = "Topics"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateTableView()
    }
    
    private func updateTableView() {
        self.featuredTopics = store.topics.filter{ $0.featured }
        self.featuredTopics.sort{ $0.position < $1.position }
        self.manager.rows = featuredTopics
    }
}

class TopicsCell: TableViewCell {

    var containerView = UIView()
    var colorStrip = UIView()
    var titleLabel = UILabel()
    var meditationsLabel = UILabel()
    
    required init?(coder: NSCoder) {
       fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: TopicsCell.description())
        
        self.containerView.layer.borderWidth = 1.0
        self.containerView.layer.borderColor = UIColor.lightGray.cgColor
        self.containerView.layer.cornerRadius = 3.0
        
        self.addSubview(self.containerView)
        
        self.containerView.addSubview(self.colorStrip)
        self.containerView.addSubview(self.titleLabel)
        self.containerView.addSubview(self.meditationsLabel)
    }

    override func configure(for item: Any) {
        guard let topic = item as? Topics.Topic else { return }
        
        self.colorStrip.backgroundColor = UIColor(hexString: topic.color)
    
        self.titleLabel.text = topic.title
        self.titleLabel.textColor = .black
        
        // Get the subtopic meditations
        let subtopics = store.subtopics.filter{$0.parent_topic_uuid == topic.uuid}
        let subtopicMeditations = subtopics.map{$0.meditations.count}.reduce(0, +)
        let totalMeditations = topic.meditations.count + subtopicMeditations
        
        self.meditationsLabel.text = "\(totalMeditations) meditations"
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
