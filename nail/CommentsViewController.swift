//
//  CommentsViewController.swift
//  nail
//
//  Created by Zhaoyu Yan on 12/13/18.
//  Copyright © 2018 Zhaoyu Yan. All rights reserved.
//

import UIKit

class CommentsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UISearchResultsUpdating{
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var contentTextField: UITextField!
    
    
    static var comments = [Comment]()
    let searchController = UISearchController(searchResultsController: nil)
    
    var nameText:String = "Please select a place"{
        didSet{
            configNameLabel()
        }
    }
    var addressText:String = "Place address"{
        didSet{
            configAddressLabel()
        }
    }
    
    func configNameLabel(){
        nameLabel.text = nameText
    }
    
    func configAddressLabel(){
        addressLabel.text = addressText
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
    }
    
    func getComments(){
        let jsonUrlStr = LoginViewController.serverUrl+"/stickies"
        guard let jsonUrl = URL(string: jsonUrlStr) else {return}
        
        URLSession.shared.dataTask(with: jsonUrl){ (data, response, err) in
            guard let data = data else {return}
            do{
                print(data)
                
                let allComment:[Comment] = try JSONDecoder().decode([Comment].self, from: data)
                print("Get comments successfully!")
                CommentsViewController.comments = allComment.filter({$0.placeId == (MainViewController.placeId ?? "")})
                if CommentsViewController.comments.count>1 {
                    CommentsViewController.comments.sort(by: {$0.likes > $1.likes})
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            }catch let jsonErr{
                print("Error serializing json:", jsonErr)
            }
            }.resume()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        search(searchController.searchBar.text!)
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func search(_ searchText: String){
        if searchText != "" {
            CommentsViewController.comments = CommentsViewController.comments.filter({ (c: Comment) -> Bool in
                return c.content.lowercased().contains(searchText.lowercased()) ?? false
            })
            tableView.reloadData()
        }else{
            getComments()
        }
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CommentsViewController.comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let comment = CommentsViewController.comments[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentsCell") as! CommentsTableViewCell
        cell.userPhotoImageView.layer.cornerRadius = 16
        cell.userNameLabel.text = comment.username
        cell.likeLabel.text = "\(comment.likes)"
        cell.contentTextView.text = comment.content
        cell.timeAgoLabel.text = comment.publishDate.toDate().timeAgo()
        let imageData = NSData(bytes: comment.userPhoto.data, length: comment.userPhoto.data.count)
        if let image = UIImage(data:(imageData as Data)) {
            cell.userPhotoImageView.image = image
        }else{
            cell.userPhotoImageView.image  = UIImage(named:"defaultPhoto")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(100)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    @IBAction func submit(_ sender: Any) {
        let noPlaceAlert = UIAlertController(title: "Alert", message: "You have not selected place yet!", preferredStyle: .alert)
        noPlaceAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        let emptyAlert = UIAlertController(title: "Alert", message: "Content Can't be empty!", preferredStyle: .alert)
        emptyAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        if MainViewController.placeId == nil || MainViewController.placeId == ""{
            present(noPlaceAlert ,animated: true, completion: nil)
        }else if contentTextField.text == nil || contentTextField.text == ""{
            present(emptyAlert, animated: true, completion: nil)
        }else{
            upLoadComment(username: LoginViewController.user!.username, userPhoto: LoginViewController.user!.photo.data, placeId: MainViewController.placeId!, placeName: MainViewController.placeName!, placeAddress: MainViewController.placeAddress!, content: self.contentTextField.text!, publishDate: Date().toString(), likes: 0)
        }
    }
    
    func upLoadComment (username:String, userPhoto:[UInt8], placeId:String, placeName:String, placeAddress:String, content:String, publishDate:String, likes: Int){
        let jsonUrlStr = LoginViewController.serverUrl+"/stickies"
        guard let jsonUrl = URL(string: jsonUrlStr) else {return}
        var request = URLRequest(url:jsonUrl)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let postJson: [String: Any] = ["username": username, "userPhoto":userPhoto, "placeId":placeId, "content":content, "placeName":placeName, "placeAddress":placeAddress, "publishDate":publishDate, "likes": likes]
        let postData = try? JSONSerialization.data(withJSONObject: postJson)
        //print(postData!)
        request.httpBody = postData
        
        URLSession.shared.dataTask(with: request){ (data, response, err) in
            //let httpResponse = response as? HTTPURLResponse
            //print(httpResponse!.statusCode)
            guard let data = data else {return}
            do{
                let comment = try JSONDecoder().decode(Comment.self, from: data)
                print(comment.content)
                DispatchQueue.main.async {
                    CommentsViewController.comments.append(comment)
                    self.tableView.reloadData()
                    self.contentTextField.text = ""
                }
                //print(user.password)
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
