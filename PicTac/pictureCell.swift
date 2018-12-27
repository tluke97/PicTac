//
//  pictureCell.swift
//  CorkBoard
//
//  Created by Tanner Luke on 10/15/17.
//  Copyright © 2017 CorkBoard Co. All rights reserved.
//

import UIKit

class pictureCell: UICollectionViewCell {
    @IBOutlet weak var pictureImage: UIImageView!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var type: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let width = UIScreen.main.bounds.width
        videoView.frame = CGRect(x: 0, y: 0, width: (width/4), height: (width/4))
        pictureImage.contentMode = .scaleAspectFill
        pictureImage.frame = CGRect(x: 0, y: -((width/4)*1.77866667)/4.4, width: (width/4) , height: (width/4)*1.77866667)
    }
}
