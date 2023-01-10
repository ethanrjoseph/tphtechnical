//
//  NetworkManager.swift
//  Ten_Percent_Technical_
//
//  Created by Ethan Joseph on 1/9/23.
//

import Foundation

final class NetworkManager {
    
    static let shared = NetworkManager()
    
    func fetchAllData() async throws {
        
        // TODO: store them all
        try await getTopics()
        try await getSubtopics()
        try await getMeditations()
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

