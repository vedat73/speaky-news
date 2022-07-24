//
//  NewsAPIManager.swift
//  SpeakyNews
//
//  Created by Vedat Ozlu on 23.07.2022.
//

import Foundation

class NewsAPIManager {
    
    private let apiURL = baseURL + "fq=tech&facet_field=day_of_week&facet=true&begin_date=20120101&end_date=20120101&api-key=" + APIKey
    
    private var imageCache = NSCache<NSString, NSData>()
    
    func fetchNewsJsonData(completion : @escaping (NewsData?)->(Void)){
        NetworkManager.shared.urlPath = self.apiURL
        NetworkManager.shared.fetchData { data, response, error in
            if let error = error {
                print("error during api request :", error.localizedDescription)
                completion(nil)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("bad response error :", NetworkManagerErrors.badResponse(response!))
                completion(nil)
                return
            }
            guard let data = data else {
                print("bad data error : ", NetworkManagerErrors.badData)
                completion(nil)
                return
            }
            let jsonResult = JSONParser()
            completion(jsonResult.DecodeJSON(data: data, codableClass: NewsData.self))
        }
    }
    func downloadImage(imgUrl : String,completion : @escaping (Data?, Error?)-> (Void)){
        
        if let imageData = self.imageCache.object(forKey: imgUrl as NSString) {
            print("cached img is used")
            completion(imageData as Data,nil)
            return
        }
        NetworkManager.shared.downloadImg(imgURL: imgUrl) { localURL, response, error in
            if let error = error {
                completion(nil,error)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("bad response error :", NetworkManagerErrors.badResponse(response!))
                completion(nil,NetworkManagerErrors.badResponse(response!))
                return
            }
            guard let localURL = localURL else {
                completion(nil,NetworkManagerErrors.badLocalUrl)
                return
            }
            do {
                let data = try Data(contentsOf: localURL)
                self.imageCache.setObject(data as NSData, forKey: imgUrl as NSString)
                completion(data,nil)
            } catch let error {
                completion(nil,error)
            }
        }
    }
}
