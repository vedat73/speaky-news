//
//  HomePageViewModel.swift
//  SpeakyNews
//
//  Created by Vedat Ozlu on 25.07.2022.
//

import Foundation
import UIKit

class ImgDownloadOperation: Operation {
    var downloadedImg : UIImage?
    var imgDownloadedHandler : ((UIImage?, Error?)-> (Void))?
    private let _imgURL : String
    private var newsApiManager : NewsAPIManager?
    init(_ _imgURL : String,_newsApiManager:NewsAPIManager?) {
        // second parameter is used for img caching issue
        self.newsApiManager = _newsApiManager
        self._imgURL = _imgURL
        self.downloadedImg = nil
        self.imgDownloadedHandler = nil
        
    }
    
    func downloadImg(imgUrl : String,completion : @escaping (UIImage?, Error?)-> (Void)) {
        if imgUrl == "nytLogo" {
            completion(UIImage(named: "nytLogo"),nil)
            return
        }
        guard let newsApiManager = self.newsApiManager else {
            completion(UIImage(named: "nytLogo"),nil)
            return
        }
        newsApiManager.downloadImage(imgUrl: baseImgURL + imgUrl) { [weak self] imgData, error in
            if error != nil {
                completion(UIImage(named: "nytLogo"),error)
            }
            if let imgData = imgData {
                if let imgDownloadedHandler = self?.imgDownloadedHandler {
                    imgDownloadedHandler(UIImage(data: imgData),nil)
                }
            } else {
                completion(UIImage(named: "nytLogo"),nil)
            }
        }
    }
    override func main() {
        if isCancelled {
            return
        }
        let randomDelayTime = arc4random_uniform(100) + 100
        usleep(randomDelayTime * 1000) // 100ms - 200 ms delay
        if isCancelled {
            return
        }
        if let imgDownloadedHandler = imgDownloadedHandler {
            self.downloadImg(imgUrl: self._imgURL) {[weak self] img, error in
                DispatchQueue.main.async {
                    if let error = error {
                        self?.downloadedImg = nil
                        self?.imgDownloadedHandler?(nil,error)
                        return
                    }
                    if let img = img {
                        self?.downloadedImg = img
                        self?.imgDownloadedHandler?(img,nil)
                    }
                    
                }
            }
        }
    }
}
class HomePageViewModel : NSObject {
    private var newsApiManager = NewsAPIManager()
    private var newsData : NewsData?
    private var homePageNewsDataArray : [HomePageData?] = [nil]
    private var homePageNewsDataItem = HomePageData()
 
    override init() {
        super.init()
        homePageNewsDataArray.reserveCapacity(11)
        
    }
    var updateNewsData : ((_ newsData : [HomePageData?] )-> Void)?
    func showDetail(homePageVC : UIViewController,homePageData : HomePageData?	){
        let newsDetail = DetailVC()
        let navCont = UINavigationController(rootViewController: newsDetail)
        navCont.modalPresentationStyle = .fullScreen
        navCont.modalTransitionStyle = .crossDissolve
        newsDetail.displayNewsDetail(homePageData ?? nil)
        homePageVC.present(navCont,animated: true)
    }
    func downloadImg(imgUrl : String)->ImgDownloadOperation? {
        return ImgDownloadOperation(imgUrl,_newsApiManager: self.newsApiManager)
    }
    func fetchNewsData(pageNumber : Int = 1){
        // for not fetching the same data, pagenumber is required
        homePageNewsDataArray.removeAll()
        DispatchQueue(label: "fetchDataFromAPI").async {
            self.newsApiManager.fetchNewsJsonData(pageNumber: pageNumber) { [weak self] jsonData in
                self?.newsData = jsonData
                guard let newsData = self?.newsData else {
                    self?.updateNewsData?([nil])
                    return
                }
                for doc in newsData.response.docs {
                    //
                    self?.homePageNewsDataItem.newsID = doc.uri
                    self?.homePageNewsDataItem.newsContent = doc.lead_paragraph
                    self?.homePageNewsDataItem.newsTitle = doc.headline.main
                    self?.homePageNewsDataItem.pub_date = doc.pub_date
                    self?.homePageNewsDataItem.source = doc.source
                    if (doc.multimedia.count>0), let imgUrl = doc.multimedia[0].url {
                        self?.homePageNewsDataItem.newsImgUrl = imgUrl
                    } else {
                        self?.homePageNewsDataItem.newsImgUrl = "nytLogo"
                    }
                    self?.homePageNewsDataArray.append(self?.homePageNewsDataItem)
                }
                self?.updateNewsData?(self?.homePageNewsDataArray ?? [nil])
            }
        }
    }
    // mergeArray : it merges two array from a specific index
    func mergeArray(_ firstArray : [HomePageData?], _ secondArray : [HomePageData?], _ fromIndex : Int) -> [HomePageData?]{
        if fromIndex == 0 {
            return  secondArray
        }
        if (firstArray != [nil]) && (secondArray != [nil]) {
            var mergedArray = firstArray
            for i in 0..<secondArray.count {
                mergedArray.insert(secondArray[i], at: fromIndex + i)
            }
            let range = (fromIndex + secondArray.count)..<mergedArray.count
            mergedArray.removeSubrange(range)
            return mergedArray
        } else {
            return [nil]
        }
        
    }
}
