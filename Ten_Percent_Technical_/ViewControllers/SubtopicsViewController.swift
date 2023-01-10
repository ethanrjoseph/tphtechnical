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
    let topic: Topics.Topic
    
    init(topic: Topics.Topic) {
        self.topic = topic
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var tableView = TableView()
    lazy var manager = SubtopicsTableViewManager(tableView: tableView)
    
    override func loadView() {
        self.view = self.tableView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        
        self.tableView.delegate = self.manager
        self.tableView.dataSource = self.manager
        
        self.title = self.topic.title
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateTableView()
    }
    
    private func updateTableView() {
        
        // TODO: with all this iteration through the mediations and subtopics I'd want to restructure some of this data as a dictionary rather than an array to make it easier to get by the uuid
        
        // Create the array of meditation sections
        var subtopicSections = store.subtopics.filter{$0.parent_topic_uuid == self.topic.uuid}.map{
            let meditations = $0.meditations.compactMap{ uuid in
                return store.meditations.first{$0.uuid == uuid}
            }
            return SubtopicSection(title: $0.title, meditations: meditations)
        }
        
        // Append the topics meditations at the end if we have any
        if self.topic.meditations.count > 0 {
            
            let meditations = self.topic.meditations.compactMap { uuid in
                return store.meditations.first{$0.uuid == uuid }
            }
            
            let section = SubtopicSection(title: "Meditations", meditations: meditations)
            subtopicSections.append(section)
        }
        
        self.manager.sections = subtopicSections
    }
}

struct SubtopicSection {
    var title: String
    var meditations: [Meditations.Meditation]
}

class SubtopicsCell: TableViewCell {

    var containerView = UIView()
    var image = UIImageView()
    var titleLabel = UILabel()
    var teacherLabel = UILabel()
    
    required init?(coder: NSCoder) {
       fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: TopicsCell.description())
        
        self.containerView.layer.borderWidth = 1.0
        self.containerView.layer.borderColor = UIColor.lightGray.cgColor
        self.containerView.layer.cornerRadius = 3.0
        
        self.addSubview(self.containerView)
        
        self.containerView.addSubview(self.image)
        self.containerView.addSubview(self.titleLabel)
        self.containerView.addSubview(self.teacherLabel)
    }

    override func configure(for item: Any) {
        guard let meditation = item as? Meditations.Meditation else { return }
    
        self.titleLabel.text = meditation.title
        self.titleLabel.textColor = .black
        
        self.teacherLabel.text = meditation.teacher_name
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.titleLabel.text = nil
        self.teacherLabel.text = nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.containerView.pin(.top)
        self.containerView.pin(.left, padding: 15)
        self.containerView.expand(.right, padding: 15)
        self.containerView.expand(.bottom, padding: 10)
        
        self.image.pin(.left, padding: 10)
        self.image.width = 60
        self.image.height = 60
        self.image.centerOnY()

        self.titleLabel.size = CGSize(width: self.contentView.width, height: 30)
        self.titleLabel.pin(.top, padding: 10)
        self.titleLabel.left = self.image.right + 10

        self.teacherLabel.numberOfLines = 0
        self.teacherLabel.width = self.contentView.width - 120
        self.teacherLabel.sizeToFit()

        self.teacherLabel.match(.top, to: .bottom, of: self.titleLabel)
        self.teacherLabel.match(.left, to: .left, of: self.titleLabel)
    }
}

class SubtopicsTableViewManager: NSObject, UITableViewDelegate, UITableViewDataSource {

    private let tableView: TableView
    var sections: [SubtopicSection] = []
    var selectionHandler: ((IndexPath) -> Void)?
    
    private var adapterList = [UITableViewCell: CellImageAdapter]()

    init(tableView: TableView) {
        self.tableView = tableView
        self.tableView.register(SubtopicsCell.self, forCellReuseIdentifier: SubtopicsCell.description())
        self.tableView.reloadData()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = self.sections[section]
        return section.meditations.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = self.sections[section]
        return section.title
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SubtopicsCell.description(), for: indexPath) as! SubtopicsCell
        let item = self.sections[indexPath.section].meditations[indexPath.row] as! Meditations.Meditation
        cell.configure(for: item)
        cell.selectionStyle = .none
        
        let adapter = getReusableAdapter(forReusableCell: cell)
        cell.image.image = nil
        cell.image.backgroundColor = .systemBlue
        
        adapter.configure(from: item.image_url) { image in
            if let image = image {
                cell.image.image = image
            }
            else{
                cell.image.backgroundColor = .systemTeal
            }
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.tableView.rowHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectionHandler?(indexPath)
    }
    
    private func getReusableAdapter(forReusableCell cell: UITableViewCell) -> CellImageAdapter {
        if let adapter = adapterList[cell]{
            return adapter
        } else{
            let adapter = CellImageAdapter()
            adapterList[cell] = adapter
            return adapter
        }
    }
}
