//
//  Login.swift
//  ChatApplication
//
//  Created by Кирилл Трискало on 06.07.2018.
//  Copyright © 2018 Кирилл Трискало. All rights reserved.
//

import UIKit
import Firebase


class Login: UIViewController, UITextFieldDelegate{
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // Кнопка нужна для возвращение на предыдущий контроллер
    @IBAction func unwindSegue(_ sender: UIStoryboardSegue) {
        
    }
    
    // Кнопка логинет пользователя и открывает ему приложение
    @IBAction func login(_ sender: Any) {
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            print("Form is not valid")
            return
        }
        
      login(email: email, password: password)
    }
    
    override func viewDidLoad() {
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }

    func login(email: String, password: String){
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                self.alertMessage(userMessage: "Неправильный логин или пароль")
                return
            }
            
            guard let user = user else { return }
            print(user.user.email ?? "нет данных о email")
            print(user.user.displayName ?? "нет данных о username")
            print(user.user.uid)
            
            // Сохраняем настройки, чтобы знать что пользователь залогинен
            UserDefaults.standard.set(true, forKey: "login")
            
            // Функция переходит в окно Чаты 
            self.openChat()
        })
    }
    
    // Функция открывает окно Чаты
    func openChat(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let tabBarController = storyboard.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
        tabBarController.selectedIndex = 1
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = tabBarController
    }
    
    // Функция вызывает уведомление об ошибке
    func alertMessage(userMessage:String){
        let myAlert = UIAlertController(title:"Ошибка", message:userMessage, preferredStyle:UIAlertControllerStyle.alert)
        let okAction=UIAlertAction(title: "Oк", style: UIAlertActionStyle.default, handler: nil)
        myAlert.addAction(okAction)
        self.present(myAlert,animated:true, completion:nil)
    }
    
    // Функция убирает клавиатуру при касание на пустое место
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // Функция по кнопке return переходит на следующее текстовое поле
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return false
    }


}
