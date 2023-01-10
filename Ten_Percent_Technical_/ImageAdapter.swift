//
//  ImageAdapter.swift
//  Ten_Percent_Technical_
//
//  Created by Ethan Joseph on 1/9/23.
//

import Foundation
import UIKit

final class ReusableCellImageAdapter {
    var latestTaskId: String = ""
    var latestTask: URLSessionDataTask?
    
    private static let sessionConfiguration: URLSessionConfiguration = {
        let configuration = URLSessionConfiguration.default
        // For each task, ignore the session cache, and load image from server
        configuration.requestCachePolicy = .reloadIgnoringCacheData
        // For each task, load image from cache, otherwise load from server
        //configuration.requestCachePolicy = .returnCacheDataElseLoad
        return configuration
    }()
    
    private static let session: URLSession = {
        let session =  URLSession(configuration: sessionConfiguration)
        return session
    }()
    
    static func cancelAllTasks() {
        session.invalidateAndCancel()
    }
    
    /// Configure and cancel old requests.
    /// This method is called from several threads (as mush as reusable cell count)
    /// There is a dependency to UIKit, but it is not dependant of UIView lifecycle.
    /// It takes the responsability to unwrap uiimage.
    func configure(from imgPath: String, completionHandler: @escaping ((UIImage?) -> ()) ) {
        guard let url = URL(string: imgPath) else { return }
        // Keep an history of the request.
        latestTaskId = UUID().uuidString
        let checkTaskId = latestTaskId
        
        // cancel the old task.
        // We don't set the reference of latestTask to nil, so that the session can still work with it.
        (latestTask != nil) ? latestTask?.cancel() : ()

        // Download the image asynchronously
        latestTask = Self.session.dataTask(with: url) { (data, response, error) in
            //Debug by increasing lag (add 50ms)
            //usleep(50_000)
            
            if let err = error {
                DispatchQueue.main.async {
                    if(self.latestTaskId == checkTaskId) {
                        completionHandler(nil)
                    }
                }
                print(err)
                return
            }
            
            // Return the image, only if the taskId match, and if
            DispatchQueue.main.async {
                if let data = data,
                   let image = UIImage(data: data){
                    // Compare the id from the class scope, with the id of the method scope
                    if(self.latestTaskId == checkTaskId) {
                        completionHandler(image)
                    }
                }
                else {
                    if(self.latestTaskId == checkTaskId) {
                        completionHandler(nil)
                    }
                }
            }
        }
        latestTask?.resume()
    }
}
