//
//  ActivUsers.swift
//  ChatApplication
//
//  Created by Кирилл Трискало on 07.07.2018.
//  Copyright © 2018 Кирилл Трискало. All rights reserved.
//

import UIKit
import Firebase

class ActivUsers: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var users = [User]()
    
    // Функция вызывается при загрузке контроллера и вызывает функцию
    override func viewDidLoad() {
        fetchUser()
    }
    
    // Функция добавляет зарегестрированых пользователей и следит не появились ли новые
    func fetchUser() {
        Database.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = User(dictionary: dictionary)
                
                // Записываются id для всех user
                user.id = snapshot.key
                self.users.append(user)
                
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
            }
        }, withCancel: nil)
    }
    
    // Фунция возвращает значения количества ячеек в таблице
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    // Фунция возвращает значения для всех UI-элементов на ячейке в таблице (label, image)
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! UsersCell
        
        let user = users[indexPath.row]
        cell.nameLabel.text = user.name
        cell.emailLabel.text = user.email
        
        // Загружается и вставляется картинка в ячейку
        if let profileImageUrl = user.profileImageUrl {
            cell.avatarImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
        }
        return cell
    }
    
    // Фунция возвращает значения размера высоты ячейки в таблице
     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    // Функция открывает чат с пользователем по нажатию на чат
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = self.users[indexPath.row]
        self.showChatControllerForUser(user)

    }
    // Функция открывает чат с пользователем
    func showChatControllerForUser(_ user: User) {
        let chatWithUser = ChatWithUser(collectionViewLayout: UICollectionViewFlowLayout())
        chatWithUser.user = user
        
        navigationController?.pushViewController(chatWithUser, animated: true)
    }

}











