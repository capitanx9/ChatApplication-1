//
//  Settings.swift
//  ChatApplication
//
//  Created by Кирилл Трискало on 09.07.2018.
//  Copyright © 2018 Кирилл Трискало. All rights reserved.
//

import UIKit
import Firebase

class Settings: UIViewController {

    @IBAction func exit(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }

        UserDefaults.standard.set(false, forKey: "login")
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let login = storyboard.instantiateViewController(withIdentifier: "login") as! UINavigationController
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = login
    }
    
}
