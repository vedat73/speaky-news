//
//  NewsCollectionViewCell.swift
//  SpeakyNews
//
//  Created by Vedat Ozlu on 24.07.2022.
//

import UIKit

class NewsCollectionViewCell: UICollectionViewCell {
    static let identifier = "NewsCollectionViewCell"
    var representedIdentifier : String = ""
    var newsImg : UIImageView = {
        let img = UIImageView()
        img.image = UIImage(systemName: "picture")
        img.contentMode = .scaleAspectFit
        img.clipsToBounds = true
        return img
    }()
    var labelTitle : UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .left
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont.boldSystemFont(ofSize: 30.0)
        return label
    }()
    var gradientView : UIView = {
        let view = UIView(frame: .zero)
        return view
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(newsImg)
        contentView.addSubview(gradientView)
        contentView.addSubview(labelTitle)
        contentView.layer.borderWidth = 3
        contentView.layer.borderColor = UIColor.darkGray.cgColor
        labelTitle.bottomAnchor.constraint(equalTo: newsImg.bottomAnchor,constant: -10).isActive = true
        labelTitle.leadingAnchor.constraint(equalTo: newsImg.leadingAnchor,constant: 15).isActive = true
        labelTitle.trailingAnchor.constraint(equalTo: newsImg.trailingAnchor,constant: -15).isActive = true
        
        gradientView.frame = contentView.frame
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = contentView.bounds
        gradientLayer.colors = [UIColor.clear.cgColor,UIColor.black.cgColor]
        gradientView.layer.addSublayer(gradientLayer)
        
        isSkeletonable = true
        contentView.isSkeletonable = true
        newsImg.isSkeletonable = true
        labelTitle.isSkeletonable = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        newsImg.frame = CGRect(x: 0, y: 0, width: contentView.frame.size.width, height: contentView.frame.size.height)
    }
    public func setNewsItem(title:String?, img : UIImage?){
        if let img = img {
            self.newsImg.image = img
        } else {
            self.newsImg.image = UIImage(systemName: "picture")
        }
        if let title = title {
            self.labelTitle.text = title
        } else {
            self.labelTitle.text = ""
        }
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        newsImg.image = UIImage(systemName: "picture")
        labelTitle.text = ""
    }
}
