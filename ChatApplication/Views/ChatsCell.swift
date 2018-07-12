//
//  ChatsCell.swift
//  ChatApplication
//
//  Created by Кирилл Трискало on 07.07.2018.
//  Copyright © 2018 Кирилл Трискало. All rights reserved.
//

import UIKit
import Firebase

class ChatsCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    // Cобираем message и заполняем все необходимые значения на cell
    var message: Message? {
        didSet {
            setupUser()
            
            messageLabel.text = message?.text // записываем сообщение
            
            if let seconds = message?.timestamp?.doubleValue {
                let timestampDate = Date(timeIntervalSince1970: seconds)
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm:ss a" // надо поменять на нормальное время
                self.timeLabel.text = dateFormatter.string(from: timestampDate) // записываем время 
            }
        }
    }
    
    // Функция загружает имя и картинку для пользователя
     func setupUser() {
        if let id = message?.chatPartnerId() {
            let ref = Database.database().reference().child("users").child(id)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in

                if let dictionary = snapshot.value as? [String: AnyObject] {
                   self.nameLabel?.text = dictionary["name"] as? String // вставляется имя

                    if let profileImageUrl = dictionary["profileImageUrl"] as? String {
                        self.avatarImageView.loadImageUsingCacheWithUrlString(profileImageUrl) // загружается вставляется картинка
                    }
                }
            }, withCancel: nil)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
