//
//  DetailVC.swift
//  SpeakyNews
//
//  Created by Vedat Ozlu on 14.08.2022.
//

import UIKit
import AVFoundation

class DetailVC: UIViewController {
    let syntesizer = AVSpeechSynthesizer()
    private var isPlayClicked = false
    let detailViewModel = DetailViewModel()
    let dateManager = DateManager("")
    let scrollView : UIScrollView = {
        let scView = UIScrollView(frame: .zero)
        scView.translatesAutoresizingMaskIntoConstraints = false
        return scView
    }()
    let contentView : UIView = {
        let mySubView = UIView()
        mySubView.translatesAutoresizingMaskIntoConstraints = false
        return mySubView
    }()
    var newsImg : UIImageView = {
        let img = UIImageView()
        img.image = UIImage(systemName: "pencil")
        img.translatesAutoresizingMaskIntoConstraints = false
        img.contentMode = .scaleAspectFit
        img.clipsToBounds = true
        return img
    }()
    var labelTitle : UILabel = {
        let label = UILabel()
        label.text = "THIS IS FOR TITLE THIS IS FOR TITLE THIS IS FOR TITLE THIS IS FOR TITLE"
        //label.backgroundColor = .red
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .left
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont.boldSystemFont(ofSize: 24.0)
        return label
    }()
    var labelPublishedDate : UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = .lightText
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.textAlignment = .left
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont.boldSystemFont(ofSize: 15.0)
        return label
    }()
    
    var labelNewsDetail : UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .justified
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont.boldSystemFont(ofSize: 17.0)
        return label
    }()
    var playPauseButton : UIBarButtonItem = {
        let btn = UIBarButtonItem()
        return btn
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        syntesizer.delegate = self
        setupViews()
    }
    
    private func setupViews() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "< News", style: .plain, target: self, action: #selector(goBack))
        playPauseButton.image = UIImage(systemName: "play.fill")
        playPauseButton.style = .plain
        playPauseButton.target = self
        playPauseButton.action = #selector(playPauseButtonClicked)
        isPlayClicked = false
        
        navigationItem.rightBarButtonItem = playPauseButton
        
        view.addSubview(scrollView)
        scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive  = true
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        scrollView.addSubview(contentView)
        
        contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor).isActive = true
        contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor).isActive = true
        
        contentView.addSubview(newsImg)
        contentView.addSubview(labelTitle)
        contentView.addSubview(labelPublishedDate)
        contentView.addSubview(labelNewsDetail)
        
        newsImg.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        newsImg.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: 10).isActive = true
        newsImg.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,constant: -10).isActive = true
        newsImg.heightAnchor.constraint(equalToConstant: 300).isActive = true

        labelTitle.topAnchor.constraint(equalTo: newsImg.bottomAnchor,constant: 15).isActive = true
        labelTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: 10).isActive = true
        labelTitle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,constant: -10).isActive = true
        
        labelPublishedDate.topAnchor.constraint(equalTo: labelTitle.bottomAnchor,constant: 5).isActive = true
        labelPublishedDate.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: 10).isActive = true
        
        labelNewsDetail.topAnchor.constraint(equalTo: labelPublishedDate.bottomAnchor,constant: 20).isActive = true
        labelNewsDetail.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: 10).isActive = true
        labelNewsDetail.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,constant: -10).isActive = true
        labelNewsDetail.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,constant: -20).isActive = true
    }
    
    @objc func playPauseButtonClicked() {
        isPlayClicked = !isPlayClicked
        if isPlayClicked {
            print("play")
            if syntesizer.isPaused {
                syntesizer.continueSpeaking()
            } else {
                let wholeText = self.labelNewsDetail.text ?? ""
                syntesizer.speak(detailViewModel.getUtterance(wholeText))
            }
            playPauseButton.image = UIImage(systemName: "stop.fill")
        } else {
            print("pause")
            if syntesizer.isSpeaking {
                syntesizer.pauseSpeaking(at: .word)
            }
            playPauseButton.image = UIImage(systemName: "play.fill")
        }
    }
    
    func displayNewsDetail(_ homePageNewsData : HomePageData?){
        guard let homePageNewsData = homePageNewsData else {
            return
        }
        self.labelTitle.text = homePageNewsData.newsTitle
        self.labelNewsDetail.text = (homePageNewsData.newsContent ?? "")
        dateManager.setDate(homePageNewsData.pub_date ?? "2022-06-16-T21:30:15+0000")
        self.labelPublishedDate.text = dateManager.convertDateFormat()// homePageNewsData.pub_date
        self.detailViewModel.downloadImg(imgUrl: (homePageNewsData.newsImgUrl)!, completion: { img, error in
            guard let img = img else {
                return
            }
            DispatchQueue.main.async {
                self.newsImg.image = img
            }
        })
    }
    @objc private func goBack() {
        dismiss(animated: true,completion: nil)
    }

}


extension DetailVC : AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        playPauseButton.image = UIImage(systemName: "play.fill")
        isPlayClicked = false
        print("finished")
    }
}
