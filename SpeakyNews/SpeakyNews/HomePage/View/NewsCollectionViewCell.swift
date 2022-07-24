//
//  NewsCollectionViewCell.swift
//  SpeakyNews
//
//  Created by Vedat Ozlu on 24.07.2022.
//

import UIKit

class NewsCollectionViewCell: UICollectionViewCell {
    static let identifier = "NewsCollectionViewCell"
    private let newsImg : UIImageView = {
        let img = UIImageView()
        img.image = UIImage(systemName: "house")
        img.contentMode = .scaleAspectFit
        img.clipsToBounds = true
        return img
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .systemPink
        contentView.addSubview(newsImg)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        newsImg.frame = CGRect(x: 0, y: 0, width: contentView.frame.size.width, height: contentView.frame.size.height)
    }
    public func setNewsItem(title:String?, imgURL : Data?){
        //title and image will be set here
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        newsImg.image = UIImage(systemName: "picture")
        // set label to nil
    }
}
