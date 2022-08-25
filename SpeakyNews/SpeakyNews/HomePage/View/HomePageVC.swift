//
//  ViewController.swift
//  SpeakyNews
//
//  Created by Vedat Ozlu on 23.07.2022.
//

import UIKit
import SkeletonView

class HomePageVC: UIViewController {
    
    private var homePageViewModel = HomePageViewModel()
    private var homePageNewsData : [HomePageData?] = []
    private var pageNumber = 1
    private let newsPageSize = 10 //page size is constant
    private var isSkeletonShowed = false
    private let imgDownloadQueue = OperationQueue()
    var imgDownloadingOperation = [IndexPath : ImgDownloadOperation]()
   
    private var collectionView : UICollectionView?
    private let labelBrand : UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "Speaky News"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name:"GillSans-UltraBold", size: 45.0)
        label.textColor = .white
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if  !isSkeletonShowed {
            collectionView?.isSkeletonable = true
            collectionView?.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .systemGray4), animation: nil, transition: .crossDissolve(0.25))
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(labelBrand)
        labelBrand.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        labelBrand.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        labelBrand.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        labelBrand.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        homePageViewModel.updateNewsData = {
            [weak self]
            newsArray in
            if let homePageNewsData = self?.homePageNewsData {
                self?.homePageNewsData = (self?.homePageViewModel.mergeArray(homePageNewsData, newsArray, (self!.pageNumber*10) - self!.newsPageSize)) ?? [nil]
            } else {
                self?.homePageNewsData = newsArray
            }
            DispatchQueue.main.async {
                self?.isSkeletonShowed = true
                self?.collectionView?.stopSkeletonAnimation()
                self?.view.hideSkeleton(reloadDataAfter: true, transition: .crossDissolve(0.25))
                self?.collectionView?.reloadData()
            }
        }
        self.homePageViewModel.fetchNewsData(pageNumber: self.pageNumber)
        setupViews()
    }
    
    func setupViews(){
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 4
        layout.minimumInteritemSpacing = 5
        layout.itemSize = CGSize(width: view.frame.size.width-10, height: 300)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView?.collectionViewLayout = layout
        collectionView?.translatesAutoresizingMaskIntoConstraints = false
        
        guard let collectionView = collectionView else {
            return
        }
        collectionView.register(NewsCollectionViewCell.self, forCellWithReuseIdentifier: NewsCollectionViewCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.prefetchDataSource = self
        view.addSubview(collectionView)
        
        collectionView.topAnchor.constraint(equalTo: labelBrand.bottomAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        collectionView.frame = view.bounds
    }
}

extension HomePageVC : UICollectionViewDelegate, SkeletonCollectionViewDataSource {
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return NewsCollectionViewCell.identifier
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        homePageViewModel.showDetail(homePageVC: self,homePageData: homePageNewsData[indexPath.item])
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewsCollectionViewCell.identifier, for: indexPath) as! NewsCollectionViewCell
        let item = homePageNewsData[indexPath.item]
        cell.representedIdentifier = item?.newsID ?? ""
        cell.newsImg.image = nil
        cell.labelTitle.text = nil
        
        let updateDownloadedImgClosure : (UIImage?, Error?)-> (Void) = {
            [weak self] img, error in
            
            guard let img = img else {
                cell.setNewsItem(title: nil, img: nil)
                return
            }
            DispatchQueue.main.async {
                cell.setNewsItem(title: item?.newsTitle, img: img)
                self?.imgDownloadingOperation.removeValue(forKey: indexPath)
            }
        }
        if let imgDownloader = imgDownloadingOperation[indexPath] {
            if let downloadedImg = imgDownloader.downloadedImg {
                // img was downloaded
                DispatchQueue.main.async {
                    cell.setNewsItem(title: item?.newsTitle, img: downloadedImg)
                    self.imgDownloadingOperation.removeValue(forKey: indexPath)
                }
            } else { //img on downloading process
                imgDownloader.imgDownloadedHandler = updateDownloadedImgClosure
            }
        } else {
            // there is no downloading operation so start one
            if let imgDownloader = homePageViewModel.downloadImg(imgUrl: item?.newsImgUrl ?? "") {
                imgDownloader.imgDownloadedHandler = updateDownloadedImgClosure
                imgDownloadQueue.addOperation(imgDownloader)
                imgDownloadingOperation[indexPath] = imgDownloader
            }
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.homePageNewsData.count
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if (indexPath.row > 0) && (indexPath.row == (homePageNewsData.count - 1)) {
            // fetch new dataset with pageNumber = (homePageNewsData.count/10 + 1)
            pageNumber = (homePageNewsData.count/10) + 1
            homePageViewModel.fetchNewsData(pageNumber: pageNumber)
            
        }
        if let _ = imgDownloadingOperation[indexPath] {
            return
        }
        
        if homePageNewsData.count<1 {
            return
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewsCollectionViewCell.identifier, for: indexPath) as! NewsCollectionViewCell
        
        let item = homePageNewsData[indexPath.item]
        cell.representedIdentifier = item?.newsID ?? ""
        let updateDownloadedImgClosure : (UIImage?, Error?)-> (Void) = {
            [weak self] img, error in
            
            guard let img = img else {
                cell.setNewsItem(title: nil, img: nil)
                return
            }
            DispatchQueue.main.async {
                cell.setNewsItem(title: item?.newsTitle, img: img)
                self?.imgDownloadingOperation.removeValue(forKey: indexPath)
            }
        }
        if let imgDownloader = imgDownloadingOperation[indexPath] {
            if let downloadedImg = imgDownloader.downloadedImg {
                // img was downloaded
                DispatchQueue.main.async {
                    cell.setNewsItem(title: item?.newsTitle, img: downloadedImg)
                    self.imgDownloadingOperation.removeValue(forKey: indexPath)
                }
            } else { //img on downloading process
                imgDownloader.imgDownloadedHandler = updateDownloadedImgClosure
            }
        } else {
            // there is no downloading operation so start one
            if let imgDownloader = homePageViewModel.downloadImg(imgUrl: item?.newsImgUrl ?? "") {
                imgDownloader.imgDownloadedHandler = updateDownloadedImgClosure
                imgDownloadQueue.addOperation(imgDownloader)
                imgDownloadingOperation[indexPath] = imgDownloader
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let imgDownloader = imgDownloadingOperation[indexPath] {
            imgDownloader.cancel()
            imgDownloadingOperation.removeValue(forKey: indexPath)
        }
    }
}

extension HomePageVC : UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        if homePageNewsData.count>9 {
            for indexPath in indexPaths {
                if let _ = imgDownloadingOperation[indexPath] {
                    return
                }
                let item = homePageNewsData[indexPath.item]
                if let itemNewsImgUrl = item?.newsImgUrl {
                    if let imgDownloader = homePageViewModel.downloadImg(imgUrl: itemNewsImgUrl) {
                        imgDownloadQueue.addOperation(imgDownloader)
                        imgDownloadingOperation[indexPath] = imgDownloader
                    }
                }
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            if let imgDownloader = imgDownloadingOperation[indexPath] {
                imgDownloader.cancel()
                imgDownloadingOperation.removeValue(forKey: indexPath)
            }
        }
    }
}



