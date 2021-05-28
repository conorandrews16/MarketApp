//
//  ImageCollectionViewCell.swift
//  Market
//
//  Created by Conor Andrews on 27/04/2021.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    func setupImageWith(itemImage: UIImage) {
        
        imageView.image = itemImage
    }
}
