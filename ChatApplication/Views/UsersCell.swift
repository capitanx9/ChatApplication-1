//
//  UserCell.swift
//  ChatApplication
//
//  Created by Кирилл Трискало on 07.07.2018.
//  Copyright © 2018 Кирилл Трискало. All rights reserved.
//

import UIKit

class UsersCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
