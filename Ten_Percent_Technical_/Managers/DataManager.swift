//
//  DataManager.swift
//  Ten_Percent_Technical_
//
//  Created by Ethan Joseph on 1/9/23.
//

import Foundation
import CoreData
import UIKit

open class DataManager: NSObject {
    
    public static let shared = DataManager()
    
    private override init() {}
    
    func retrieveAppState(with container: NSPersistentContainer) -> ([Topics.Topic], [Subtopics.Subtopic], [Meditations.Meditation])? {
        let managedContext = container.viewContext
        
        let topicFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Topic")
        let subtopicFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Subtopic")
        let meditationFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Meditation")
        
        
        guard let topicResult = try? managedContext.fetch(topicFetchRequest) as? [NSManagedObject],
              let subtopicResult = try? managedContext.fetch(subtopicFetchRequest) as? [NSManagedObject],
              let meditationResult = try? managedContext.fetch(meditationFetchRequest) as? [NSManagedObject] else { return nil }
        
        // If we have topics, assume we've already fetched the data
        guard topicResult.count > 0  else { return nil }
        return (topicResult.map{Topics.Topic(json: convertItemToDict($0))},
                subtopicResult.map{Subtopics.Subtopic(json: convertItemToDict($0))},
                meditationResult.map{Meditations.Meditation(json: convertItemToDict($0))})
        
    }
    
    func saveAppState(_ state: AppStateStore, container: NSPersistentContainer) {
        let managedContext = container.viewContext
        
        for topic in store.topics {
            let topicObject = NSEntityDescription.insertNewObject(forEntityName: "Topic", into: managedContext)
            topicObject.setValue(topic.uuid, forKey: "uuid")
            topicObject.setValue(topic.title, forKey: "title")
            topicObject.setValue(topic.position, forKey: "position")
            topicObject.setValue(topic.meditations, forKey: "meditations")
            topicObject.setValue(topic.featured, forKey: "featured")
            topicObject.setValue(topic.color, forKey: "color")
        }
        
        for subtopic in store.subtopics {
            let subtopicObject = NSEntityDescription.insertNewObject(forEntityName: "Subtopic", into: managedContext)
            
            subtopicObject.setValue(subtopic.uuid, forKey: "uuid")
            subtopicObject.setValue(subtopic.title, forKey: "title")
            subtopicObject.setValue(subtopic.position, forKey: "position")
            subtopicObject.setValue(subtopic.meditations, forKey: "meditations")
            subtopicObject.setValue(subtopic.parent_topic_uuid, forKey: "parent_topic_uuid")
        }
        
        for meditation in store.meditations {
            let meditationObject = NSEntityDescription.insertNewObject(forEntityName: "Meditation", into: managedContext)
            
            meditationObject.setValue(meditation.uuid, forKey: "uuid")
            meditationObject.setValue(meditation.title, forKey: "title")
            meditationObject.setValue(meditation.teacher_name, forKey: "teacher_name")
            meditationObject.setValue(meditation.image_url, forKey: "image_url")
            meditationObject.setValue(meditation.play_count, forKey: "play_count")
        }
        
        // Attempt to save
        do {
            print("Saving data")
            try managedContext.save()
        } catch let error as NSError {
            print("Failed to save data! \(error): \(error.userInfo)")
        }
    }
}

/// Converts NSManagedObject to JSON array
func convertToJSONArray(moArray: [NSManagedObject]) -> Any {
    var jsonArray: [[String: Any]] = []
    for item in moArray {
        let dict = convertItemToDict(item)
        jsonArray.append(dict)
    }
    return jsonArray
}

func convertItemToDict(_ item: NSManagedObject) -> [String: Any] {
    var dict: [String: Any] = [:]
    for attribute in item.entity.attributesByName {
        
        // Check if value is present
        if let value = item.value(forKey: attribute.key) {
            dict[attribute.key] = value
        }
    }
    return dict
}
