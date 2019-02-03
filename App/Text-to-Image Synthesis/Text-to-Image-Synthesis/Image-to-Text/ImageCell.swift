//
//  ImageCell.swift
//  Text-to-Image-Synthesis
//
//  Created by Ryan Kang on 1/16/19.
//

import UIKit

class ImageCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    var isImageLoaded: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        isSelected = false
    }
}
