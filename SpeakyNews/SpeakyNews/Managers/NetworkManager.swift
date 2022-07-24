//
//  NetworkManager.swift
//  SpeakyNews
//
//  Created by Vedat Ozlu on 23.07.2022.
//

import Foundation
class NetworkManager {
    static var shared = NetworkManager()
    var urlPath : String?
    
    func fetchData(completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        guard let urlPath = urlPath else {
            return
        }
        let url = URL(string: urlPath)
        let session = URLSession.shared
        let task  = session.dataTask(with: url!) {data, response, error in
            completionHandler(data,response,error)
        }
        task.resume()
        
    }
    
    func downloadImg(imgURL : String,completionHandler: @escaping (URL?, URLResponse?, Error?)-> Void) {
        let url = URL(string: imgURL)
        let session = URLSession.shared
        let task  = session.downloadTask(with: url!) { localURL, response, error in
            completionHandler(localURL,response,error)
        }
        task.resume()
        
    }
}

