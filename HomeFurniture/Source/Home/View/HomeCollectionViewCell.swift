//
//  HomeCollectionViewCell.swift
//  HomeFurniture
//
//  Created by sudeep.r on 11/02/18.
//  Copyright © 2018 sudeep.r. All rights reserved.
//

import UIKit

class HomeCollectionViewCell: UICollectionViewCell {
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    var info: FurnitureInfo! {
        didSet {
            guard let _ = info,
                let title = info.title,
                let imageData = info.imageData else {return}
            titleLabel.text = title
            imageView.image = UIImage(data: imageData)
            detailLabel.text = info.detail?.isEmpty == false ? info.detail : ""
        }
    }
        
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.layer.cornerRadius = 5
        self.clipsToBounds = true
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.black.cgColor
    }
        
}
