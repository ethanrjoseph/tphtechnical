//
//  NetworkManager.swift
//  Ten_Percent_Technical_
//
//  Created by Ethan Joseph on 1/9/23.
//

import Foundation

final class NetworkManager {
    
    static let shared = NetworkManager()

    func getTopics() async throws -> Topics {
        var request = URLRequest(url: Endpoints.topics)
        request.httpMethod = Methods.get.rawValue
        
        //TODO: try without these
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(Topics.self, from: data)
    }
    
    enum Methods: String {
        case get = "GET"
    }
}

struct Endpoints {
    
    //TODO: pull out base URL
    static let topics = URL(string: "https://tenpercent-interview-project.s3.amazonaws.com/topics.json")!
    static let subtopics = URL(string: "https://tenpercent-interview-project.s3.amazonaws.com/subtopics.json")!
    static let meditations = URL(string: " https://tenpercent-interview-project.s3.amazonaws.com/meditations.json")!
    
}

// MARK: Models

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

struct Subtopic: Decodable  {
    var uuid: String
    var parent_topic_uuid: String
    var title: String
    var position: Int
    var meditations: [String]
}

struct Meditation: Decodable {
    var uuid: String
    var title: String
    var teacher_name: String
    var image_url: String
    var play_count: Int
}
