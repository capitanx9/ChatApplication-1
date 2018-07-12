//
//  Regestration.swift
//  ChatApplication
//
//  Created by Кирилл Трискало on 06.07.2018.
//  Copyright © 2018 Кирилл Трискало. All rights reserved.
//

import UIKit
import Firebase

class Regestration: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!

    var textAlert: String = ""

    // Кнопка открывает галерею и дает возможность выбрать картинку и вставить ее в avatarImageView
    @IBAction func addPicture(_ sender: Any) {
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerControllerSourceType.photoLibrary
        image.allowsEditing = false
        
        self.present(image, animated: true){
        }
    }
    
    // Функция запускается при загрузке контроллера и подключает делегаты для текстовых полей
    override func viewDidLoad() {
        configureTextFields()
    }
    
    // Функция запускается при появлении контроллера и подключает наблюдателей
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addObservers()
    }
    
    // Функция запускается при исчезновении контроллера и удаляет наблюдателей
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeObservers()
    }
    
    // Функция подключает делегаты для текстовых полей 
    func configureTextFields(){
        nameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    // Функция, вызывающаяся вместе с кнпокой addPicture, котороя открывает галерею и вставляет картинку 
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage{
            profileImageView.image = image
        }
        else{
            print("Какая-то ошибка")
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    // Кнопка вызывает функцию, ответственную за регестрацию пользователя
    @IBAction func regestration(_ sender: Any) {
        registerUser()
    }
    
    // Функция регестрирует пользователя
    func registerUser() {
        
        let result = checkAllValidation(pass: passwordTextField.text, eml: emailTextField.text)
        if result == true{
           
            guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text else {
                print("Form is not valid")
                return
            }
            
            Auth.auth().createUser(withEmail: email, password: password) { (result: AuthDataResult?, error) in
                if error != nil {
                    print(error ?? "")
                    return
                }
                
                guard let uid = result?.user.uid else {
                    return
                }
                
                let imageName = UUID().uuidString // генератор случайного uiid
                let storageRef = Storage.storage().reference().child("profile_images").child("\(imageName).jpg")
                
                // Если есть картинка, то она конвертируется из Image в Data
                if let profileImage = self.profileImageView.image, let uploadData = UIImageJPEGRepresentation(profileImage, 0.1) {
       
                    // Функция putData загружает картинку в Storage
                    storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                        if error != nil {
                            print(error ?? "")
                            return
                        }
                        
                        // Функция  downloadURL загружает url из текущей сессии, чтобы уже добавить в Database
                        // потом по этой url можно будет загрузить картинку
                        storageRef.downloadURL(completion: { (url, error) in
                            if error != nil {
                                print(error!.localizedDescription)
                                return
                            }
                            
                            if let profileImageUrl = url?.absoluteString {
                                let values = ["name": name, "email": email, "profileImageUrl": profileImageUrl]
                                self.saveUserInDatabase(uid, values: values as [String : AnyObject])
                            }
                        })
                    })
                }
            }
        }else{
            alertMessage(userMessage: textAlert)
        }
    }
    
    // Функция записывает данные о пользователе в базу данных
    fileprivate func saveUserInDatabase(_ uid: String, values: [String: AnyObject]) {
        let ref = Database.database().reference()
        let usersReference = ref.child("users").child(uid)
        
        usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            if err != nil {
                print(err ?? "")
                return
            }
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let tabBarController = storyboard.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
            tabBarController.selectedIndex = 1
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = tabBarController
        })
    }
    
    // Функция проверяет на валидацию email
    func isValidEmail(email: String) -> Bool {
        let emailTest = NSPredicate(format:"SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}")
        return emailTest.evaluate(with: email)
    }
    
    // Функция проверяет на валидацию пароль
    func isValidPassword(password: String)->Bool{
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[A-Z])(?=.*[a-z].*[a-z])(?=.*[0-9].*[0-9].*[0-9]).{8,}$")
        let result = passwordTest.evaluate(with: password)
        
        return result
    }
    
    // Функция проверяет на валидацию подфункции и реагирует в зависимости от возвращаемых значений
    func checkAllValidation(pass:String?, eml:String?)->Bool{
        
        var result1: Bool = false
        var result2: Bool = false
        var result3: Bool = false
        
        var passwordForCheck: String?
        var emailForCheck: String?
        
        passwordForCheck = pass ?? "ничего"
        emailForCheck = eml ?? "ничего"
        
        if nameTextField.text ==  "" || passwordTextField.text == "" || emailTextField.text == ""{
            textAlert = "Не заполненны текстовые поля\n"
        }else{
            result1 = true
        }
        
        if isValidEmail(email: emailForCheck!) == false{
            result2 = isValidEmail(email: emailForCheck!)
            textAlert += "Некоректный введенный email-адрес\n"
        }else{
            result2 = true
        }
        
        if isValidPassword(password: passwordForCheck!) == false{
            result3 = isValidPassword(password: passwordForCheck!)
            textAlert += "Ненадежный пароль. Пароль должен содержать: 1 большую букву, 2 маленьких, 3 цифры и быть не меньше 8 символов\n"
        }else{
            result3 = true
        }
        
        print("\(result1), \(result2), \(result3)")
        if result1 == true, result2 == true, result3 == true{
            return true
        }else{
            return false
        }
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
   
    func didTapView(gesture: UITapGestureRecognizer){
        view.endEditing(true)
    }
    
    // Функция добавляет наблюдателей, которые следят за изменением клавиатуры
    func addObservers(){
        NotificationCenter.default.addObserver(forName: .UIKeyboardWillShow, object: nil, queue: nil) { (notification) in
            self.keyboardWillShow(notification: notification)
        }
        NotificationCenter.default.addObserver(forName: .UIKeyboardWillHide, object: nil, queue: nil) { (notification) in
            self.keyboardWillHide(notification: notification)
        }
    }
    
    // Функция реагирует на появиление клавиатуры и отступает соответсвующее растояние
    func keyboardWillShow(notification: Notification){
        guard let userInfo = notification.userInfo,
            let frame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else{
                return
        }
        let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: frame.height + 20, right: 0)
        scrollView.contentInset = contentInset
    }
    
    // Функция реагирует на исчезновение клавиатуры и отступает на соответсвующее растояние
    func keyboardWillHide(notification: Notification){
        scrollView.contentInset = UIEdgeInsets.zero
    }
    
    // Функция удаляет наблюдателей
    func removeObservers(){
        NotificationCenter.default.removeObserver(self)
    }

}
