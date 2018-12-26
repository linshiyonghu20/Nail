//
//  SignupViewController.swift
//  nail
//
//  Created by Zhaoyu Yan on 12/11/18.
//  Copyright © 2018 Zhaoyu Yan. All rights reserved.
//

import UIKit

class SignupViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate{
    let imagePicker = UIImagePickerController()
    
    var photo = UIImage(named: "defaultPhoto")
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var password1TextField: UITextField!
    @IBOutlet weak var password2TextField: UITextField!
    @IBOutlet weak var usernameAlert: UILabel!
    @IBOutlet weak var password1Alert: UILabel!
    @IBOutlet weak var password2Alert: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        initImageView()
        
        
        // Do any additional setup after loading the view.
    }
    
    func initImageView(){
        imageView.image = photo
        imageView.layer.cornerRadius = imageView.bounds.width/2
    }
    
    @IBAction func pickImage(_ sender: Any) {
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            imageView.image = image
            photo = image
        }
        dismiss(animated: true, completion: nil)
    }

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if textField == usernameTextField{
            if !textField.text!.isEmpty{
                if LoginViewController.users.contains(where: {$0.username == textField.text!}){
                    usernameAlert.isHidden = false
                }else{
                    usernameAlert.isHidden = true
                }
            }
        }
        
        if textField == password1TextField{
            if !textField.text!.isEmpty && !password2TextField.text!.isEmpty{
                if textField.text! != password2TextField.text!{
                    password1Alert.isHidden = false
                    password2Alert.isHidden = false
                }else{
                    password1Alert.isHidden = true
                    password2Alert.isHidden = true
                }
            }
        }
        
        if textField == password2TextField{
            if !textField.text!.isEmpty && !password1TextField.text!.isEmpty{
                if textField.text! != password1TextField.text!{
                    password1Alert.isHidden = false
                    password2Alert.isHidden = false
                }else{
                    password1Alert.isHidden = true
                    password2Alert.isHidden = true
                }
            }
        }
        return true
    }
    
    @IBAction func submit(_ sender: Any) {
        let invalidAlert = UIAlertController(title: "Alert", message: "Information invalid!", preferredStyle: .alert)
        invalidAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        if usernameTextField.text!.isEmpty || usernameTextField.text == nil ||
            password1TextField.text!.isEmpty || password1TextField.text == nil ||  password2TextField.text!.isEmpty || password2TextField.text == nil || password1TextField.text! != password2TextField.text! || LoginViewController.users.contains(where: {$0.username == usernameTextField.text!}){
            present(invalidAlert, animated: true, completion: nil)
        }else{
            //print("press")
            //let newUser = User(username: usernameTextField.text!, password: password1TextField.text!, photo: imageView.image!.jpegData(compressionQuality: 1)! )
            upLoadUser(username: usernameTextField.text!, password: password1TextField.text!, photo: imageView.image!.jpegData(compressionQuality: 0.5)!)
            //LoginViewController.users.append(newUser)
            dismiss(animated: true, completion: nil)
        }
    }
    
    func upLoadUser(username:String, password: String, photo:Data){
        let jsonUrlStr = LoginViewController.serverUrl+"/users"
        guard let jsonUrl = URL(string: jsonUrlStr) else {return}
        var request = URLRequest(url:jsonUrl)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let photoDataArr = [UInt8](photo)
        let postJson: [String: Any] = ["username": username, "password": password, "photo":photoDataArr]
        let postData = try? JSONSerialization.data(withJSONObject: postJson)
        //print(postData!)
        request.httpBody = postData
        
        URLSession.shared.dataTask(with: request){ (data, response, err) in
            //let httpResponse = response as? HTTPURLResponse
            //print(httpResponse!.statusCode)
            guard let data = data else {return}
            do{
                let user = try JSONDecoder().decode(User.self, from: data)
                print(user.username)
                DispatchQueue.main.async {
                    LoginViewController.users.append(user)
                }
            }catch let jsonErr{
                print("Error serializing json:", jsonErr)
            }
        }.resume()
    }
    
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
