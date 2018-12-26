//
//  CommentsTableViewCell.swift
//  nail
//
//  Created by Zhaoyu Yan on 12/14/18.
//  Copyright © 2018 Zhaoyu Yan. All rights reserved.
//

import UIKit

class CommentsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userPhotoImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var timeAgoLabel: UILabel!
    @IBOutlet weak var likeBtn: UIButton!
    
    @IBAction func pressLikeBtn(_ sender: Any) {
        likeBtn.setTitleColor(.red, for: .normal)
        let likeNum = Int(likeLabel.text ?? "0")
        likeLabel.text = String(likeNum!+1)
        likeLabel.textColor = .red
    }
    
}
