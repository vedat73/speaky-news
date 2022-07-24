//
//  ViewController.swift
//  SpeakyNews
//
//  Created by Vedat Ozlu on 23.07.2022.
//

import UIKit

class HomePageVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    private var newsApiManager = NewsAPIManager()
    private var newsData : NewsData?
    let myImg : UIImageView = {
       let img = UIImageView(frame: CGRect(x: 50, y: 50, width: 300, height: 300))
       return img
    }()
    private var collectionView : UICollectionView?
    
    private let btn : UIButton = {
        let btn = UIButton(frame: CGRect(x: 50, y: 400, width: 100, height: 25))
        btn.setTitle("ShowImg", for: UIControl.State.normal)
        btn.backgroundColor = .blue
        return btn
    }()
    
    @objc func didClicked(){
        self.newsApiManager.downloadImage(imgUrl: baseImgURL + "images/2012/01/02/arts/jp-book/jp-book-jumbo.jpg") { [weak self] imgData, error in
            if error != nil {
                let image = UIImage(systemName: "picture")
                DispatchQueue.main.async {
                    self?.myImg.image = image
                }
            }
            if let imgData = imgData {
                let image = UIImage(data: imgData)
                DispatchQueue.main.async {
                    self?.myImg.image = image
                }
            }
        }
        print("btn clicked")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 4
        layout.minimumInteritemSpacing = 5
        layout.itemSize = CGSize(width: view.frame.size.width-10, height: 300)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.addSubview(myImg)
        view.addSubview(btn)
        guard let collectionView = collectionView else {
            return
        }
        collectionView.register(NewsCollectionViewCell.self, forCellWithReuseIdentifier: NewsCollectionViewCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        view.addSubview(collectionView)
        collectionView.frame = view.bounds
        view.backgroundColor = .green
        btn.addTarget(self, action: #selector(didClicked), for: .touchUpInside)
        
        DispatchQueue(label: "fetchDataFromAPI").async {
            self.newsApiManager.fetchNewsJsonData { [weak self]  jsonData in
                self?.newsData = jsonData
                guard let newsData = self?.newsData else {
                    return
                }
                print(newsData.response.docs[0].abstract ?? "abstract is nil")

            }
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewsCollectionViewCell.identifier, for: indexPath) as! NewsCollectionViewCell
        // cell.contentView.backgroundColor = .systemBlue
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    


}

