//
//  DetailViewModel.swift
//  SpeakyNews
//
//  Created by Vedat Ozlu on 15.08.2022.
//

import UIKit
import AVFoundation

class DetailViewModel  {
    
    private var newsApiManager = NewsAPIManager()
    private let homePageViewModel = HomePageViewModel()
    var updateNewsDetail : ((_ newsDetails : DetailPageData? )-> Void)?
    
    init() {
        print("init")
    }
    func downloadImg(imgUrl : String,completion : @escaping (UIImage?, Error?)-> (Void)) {
        if imgUrl == "nytLogo" {
            completion(UIImage(named: "nytLogo"),nil)
            return
        }
        self.newsApiManager.downloadImage(imgUrl: baseImgURL + imgUrl) { [weak self] imgData, error in
            if error != nil {
                completion(UIImage(named: "nytLogo"),error)
            }
            if let imgData = imgData {
                completion(UIImage(data: imgData),nil)
            } else {
                completion(UIImage(named: "nytLogo"),nil)
            }
        }
    }
    func getUtterance(_ speechString: String) -> AVSpeechUtterance {
        let utterance = AVSpeechUtterance(string: speechString)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.4
        return utterance
    }
}

