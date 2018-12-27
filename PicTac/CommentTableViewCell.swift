//
//  CommentTableViewCell.swift
//  CorkBoard
//
//  Created by Tanner Luke on 11/5/17.
//  Copyright © 2017 CorkBoard Co. All rights reserved.
//

import UIKit
import KILabel

class CommentTableViewCell: UITableViewCell {
    @IBOutlet weak var usernameButton: UIButton!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var commentText: KILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //commentText.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        
        
        
        
        
        
        usernameButton.translatesAutoresizingMaskIntoConstraints = false
        profilePic.translatesAutoresizingMaskIntoConstraints = false
        commentText.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat:
            "V:|-5-[username]-(-2)-[comment]-5-|", options: [], metrics: nil, views: ["username" : usernameButton, "comment" : commentText]))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat:
            "V:|-15-[date]", options: [], metrics: nil, views: ["date" : timeLabel]))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat:
            "V:|-10-[profile(40)]", options: [], metrics: nil, views: ["profile" : profilePic]))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat:
            "H:|-10-[profile(40)]-13-[comment]-20-|", options: [], metrics: nil, views: ["profile" : profilePic, "comment" : commentText]))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat:
            "H:[profile]-13-[username]", options: [], metrics: nil, views: ["profile":profilePic, "username":usernameButton]))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat:
            "H:[date]-10-|", options: [], metrics: nil, views: ["date":timeLabel]))
        profilePic.layer.cornerRadius = profilePic.frame.size.width / 2
        profilePic.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
