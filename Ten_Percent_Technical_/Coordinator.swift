//
//  Coordinator.swift
//  Ten_Percent_Technical_
//
//  Created by Ethan Joseph on 1/9/23.
//

import Foundation

import UIKit

protocol Coordinator {
    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController { get set }

    func start()
}

class MainCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.navigationController.navigationBar.prefersLargeTitles = true
    }

    func start() {
        let vc = TopicsViewController(delegate: self)
        navigationController.pushViewController(vc, animated: false)
    }
    
    private func pushSubTopics(for topic: Topics.Topic) {
        let vc = SubtopicsViewController(topic: topic)
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
}

extension MainCoordinator: TopicsViewControllerDelegate {
    func topicsViewController(didSelect: Topics.Topic, _ controller: TopicsViewController) {
        self.pushSubTopics(for: didSelect)
    }
}


