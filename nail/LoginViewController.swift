//
//  LoginViewController.swift
//  nail
//
//  Created by Zhaoyu Yan on 12/11/18.
//  Copyright © 2018 Zhaoyu Yan. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate{
    
    static var users:[User] = []
    static var user:User?
    static let serverUrl:String = "http://24.62.61.206:3000"
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUsers()
        //LoginViewController.users.append(User(username: "q", password: "q", photo: UIImage(named: "defaultPhoto")!.jpegData(compressionQuality: 1)!))
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        MainViewController.placeId = ""
        MainViewController.placeName = ""
        MainViewController.placeAddress = ""
        CommentsViewController.comments = []
        UserDetailViewController.userComments = []
    }
    
    @IBAction func login(_ sender: Any) {
        let invalidAlert = UIAlertController(title: "Alert", message: "User name and password don't match!", preferredStyle: .alert)
        invalidAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        if LoginViewController.users.contains(where: {
            if $0.username == usernameTextField.text! && $0.password == passwordTextField.text!{
                LoginViewController.user = $0
                return true
            }else{
                return false
            }
        }){
            usernameTextField.text = ""
            passwordTextField.text = ""
            performSegue(withIdentifier: "toMainView", sender: self)
        }else{
            usernameTextField.text = ""
            passwordTextField.text = ""
            present(invalidAlert,animated: true, completion: nil)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func getUsers(){
        let jsonUrlStr = LoginViewController.serverUrl+"/users"
        guard let jsonUrl = URL(string: jsonUrlStr) else {return}
        
        URLSession.shared.dataTask(with: jsonUrl){ (data, response, err) in
            guard let data = data else {return}
            do{
                LoginViewController.users = try JSONDecoder().decode([User].self, from: data)
                print("Get users successfully!")
                //print(user.photo)
            }catch let jsonErr{
                print("Error serializing json:", jsonErr)
            }
            }.resume()
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
