//
//  Chats.swift
//  ChatApplication
//
//  Created by Кирилл Трискало on 06.07.2018.
//  Copyright © 2018 Кирилл Трискало. All rights reserved.
//

import UIKit
import Firebase

class Chats: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegateFlowLayout  {

    @IBOutlet weak var tableView: UITableView!
    var timer: Timer?
    var messages = [Message]()
    var messagesDictionary = [String: Message]()
    
    // Функция вызывается при загрузке контроллера и вызывает функцию 
    override func viewDidLoad() {
        observeUserMessages()
    }
    
    // Функция наблюдает не появились ли новые сообщения от пользователей
    func observeUserMessages() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
    
        let ref = Database.database().reference().child("user-messages").child(uid)
        ref.observe(.childAdded, with: { (snapshot) in
            
            // Получаем все ключи для всех message
            let messageId = snapshot.key
            let messageReference = Database.database().reference().child("messages").child(messageId)
            
            messageReference.observeSingleEvent(of: .value, with: { (snapshot) in
       
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    
                    // получаем все сообщения пользователя 
                    let message = Message(dictionary: dictionary)
                    
                    // для каждого messages получаем id
                    if let chatPartnerId = message.chatPartnerId() {
  
                        // каждый месседж сортируется по id отправителя
                        self.messagesDictionary[chatPartnerId] = message
                        
                        // значения словарей мы передаем в messages и у нас появляется 2 массива
                        self.messages = Array(self.messagesDictionary.values)
                        
                        // сортируем messages по времени
                        self.messages.sort(by: { (message1, message2) -> Bool in
                            return (message1.timestamp?.intValue)! > (message2.timestamp?.intValue)!
                        })
                    }
                    
                    // Здесь запускается функция handleReloadTable, которая обновляет tableView через интервал времени
                    self.timer?.invalidate()
                    self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
                }
            }, withCancel: nil)
        }, withCancel: nil)
    }
    
    // Фунция перегружает tableView
    @objc func handleReloadTable() {
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }
    
    // Фунция возвращает значения количества ячеек в таблице
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    // Фунция возвращает значения для всех UI-элементов на ячейке в таблице (label, image)
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ChatsCell
        let message = messages[indexPath.row]
        cell.message = message
        return cell
    }
    
    // Фунция возвращает значения размера высоты ячейки в таблице
     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    // Функция открывает чат с пользователем по нажатию на чат 
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        
       // В chatPartnerId записываем id пользователя с каким мы общаемся
        guard let chatPartnerId = message.chatPartnerId() else { return }
        
        let ref = Database.database().reference().child("users").child(chatPartnerId)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
            let user = User(dictionary: dictionary)
            
            // Записываем для собеседника его uid, чтобы потом фильтровать сообщения для чата
            user.id = chatPartnerId
            // Вызывем функцию которая открывает чат с пользователем
            self.showChatControllerForUser(user)
            
        }, withCancel: nil)
        
    }

    // Функция открывает чат с пользователем
     func showChatControllerForUser(_ user: User) {
        let chatWithUser = ChatWithUser(collectionViewLayout: UICollectionViewFlowLayout())
        chatWithUser.user = user

        navigationController?.pushViewController(chatWithUser, animated: true)
    }
}
