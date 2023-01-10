//
//  NetworkManager.swift
//  Ten_Percent_Technical_
//
//  Created by Ethan Joseph on 1/9/23.
//

import Foundation

final class NetworkManager {
    
    static let shared = NetworkManager()
    
    /// Attempts to fetch all data over the network
    func fetchAllData() async throws {
        
        let topics = try await getTopics()
        let subtopics = try await getSubtopics()
        let mediations = try await getMeditations()
        
        
        // Add data to the shared store
        store.topics = topics.topics
        store.subtopics = subtopics.subtopics
        store.meditations = mediations.meditations
        
        // Store what we retrieved in core data
        DataManager.shared.saveAppState(store)
    }

    private func getTopics() async throws -> Topics {
        var request = URLRequest(url: Endpoints.topics)
        request.httpMethod = Methods.get.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(Topics.self, from: data)
    }
    
    private func getSubtopics() async throws -> Subtopics {
        var request = URLRequest(url: Endpoints.subtopics)
        request.httpMethod = Methods.get.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(Subtopics.self, from: data)
    }
    
    private func getMeditations() async throws -> Meditations {
        var request = URLRequest(url: Endpoints.meditations)
        request.httpMethod = Methods.get.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(Meditations.self, from: data)
    }
    
    enum Methods: String {
        case get = "GET"
    }
}

struct Endpoints {
    
    //TODO: pull out base URL
    static let topics = URL(string: "https://tenpercent-interview-project.s3.amazonaws.com/topics.json")!
    static let subtopics = URL(string: "https://tenpercent-interview-project.s3.amazonaws.com/subtopics.json")!
    static let meditations = URL(string: "https://tenpercent-interview-project.s3.amazonaws.com/meditations.json")!
    
}

// MARK: Models

class AppStateStore {
    
    private init() {}
    
    static var shared = AppStateStore()
    
    var topics: [Topics.Topic] = []
    var subtopics: [Subtopics.Subtopic] = []
    var meditations: [Meditations.Meditation] = []
}

struct Topics: Decodable {
    var topics: [Topic]
    
    struct Topic: Decodable {
        var uuid: String
        var title: String
        var position: Int
        var meditations: [String]
        var featured: Bool
        var color: String
    }
}

struct Subtopics: Decodable {
    
    var subtopics: [Subtopic]
    
    struct Subtopic: Decodable  {
        var uuid: String
        var parent_topic_uuid: String
        var title: String
        var position: Int
        var meditations: [String]
    }
}

struct Meditations: Decodable {
    
    var meditations: [Meditation]
    
    struct Meditation: Decodable {
        var uuid: String
        var title: String
        var teacher_name: String
        var image_url: String
        var play_count: Int?
    }
}

// MARK: Core data models

public class TopicObject: NSObject {
    
    var uuid: String
    var title: String
    var position: Int
    var meditations: [String]
    var featured: Bool
    var color: String
    
    convenience init(topic: Topics.Topic) {
        self.init(uuid: topic.uuid, title: topic.title, position: topic.position, meditations: topic.meditations, featured: topic.featured, color: topic.color)
    }
    
    init(uuid: String, title: String, position: Int, meditations: [String], featured: Bool, color: String) {
        self.uuid = uuid
        self.title = title
        self.position = position
        self.meditations = meditations
        self.featured = featured
        self.color = color
    }
}

public class SubtopicObject: NSObject {
    var uuid: String
    var parent_topic_uuid: String
    var title: String
    var position: Int
    var meditations: [String]
    
    convenience init(subtopic: Subtopics.Subtopic) {
        self.init(uuid: subtopic.uuid, parent_topic_uuid: subtopic.parent_topic_uuid, title: subtopic.title, position: subtopic.position, meditations: subtopic.meditations)
    }
    
    init(uuid: String, parent_topic_uuid: String, title: String, position: Int, meditations: [String]) {
        self.uuid = uuid
        self.parent_topic_uuid = parent_topic_uuid
        self.title = title
        self.position = position
        self.meditations = meditations
    }
}

public class MeditationObject: NSObject {
    var uuid: String
    var title: String
    var teacher_name: String
    var image_url: String
    var play_count: Int?
    
    convenience init(meditation: Meditations.Meditation) {
        self.init(uuid: meditation.uuid, title: meditation.title, teacher_name: meditation.teacher_name, image_url: meditation.image_url, play_count: meditation.play_count)
    }
    
    init(uuid: String, title: String, teacher_name: String, image_url: String, play_count: Int? = nil) {
        self.uuid = uuid
        self.title = title
        self.teacher_name = teacher_name
        self.image_url = image_url
        self.play_count = play_count
    }
}


