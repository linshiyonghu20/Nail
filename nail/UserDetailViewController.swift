//
//  UserDetailViewController.swift
//  nail
//
//  Created by Zhaoyu Yan on 12/14/18.
//  Copyright © 2018 Zhaoyu Yan. All rights reserved.
//

import UIKit
import GooglePlaces

class UserDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UISearchResultsUpdating{
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userPhotoImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    static var userComments = [Comment]()
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUserDetail()
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        getComments()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getComments()
    }
    
    func initUserDetail(){
        userNameLabel.text = LoginViewController.user!.username
        let imageData = NSData(bytes: LoginViewController.user!.photo.data, length: LoginViewController.user!.photo.data.count)
        userPhotoImageView.layer.cornerRadius = userPhotoImageView.bounds.width/2
        userPhotoImageView.image = UIImage(data: imageData as Data)
 
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
                UserDetailViewController.userComments = allComment.filter({$0.username == LoginViewController.user!.username})
                if UserDetailViewController.userComments.count>1 {
                    UserDetailViewController.userComments.sort(by: {$0.likes > $1.likes})
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
            UserDetailViewController.userComments = UserDetailViewController.userComments.filter({ (c: Comment) -> Bool in
                return c.content.lowercased().contains(searchText.lowercased()) ?? false
            })
            tableView.reloadData()
        }else{
            getComments()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return UserDetailViewController.userComments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let comment = UserDetailViewController.userComments[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCommentsCell") as! UserCommentsTableViewCell
        cell.placeNameLabel.text = comment.placeName
        cell.addressLabel.text = comment.placeAddress
        cell.likeLabel.text = "\(comment.likes)"
        cell.contentTextView.text = comment.content
        cell.timeAgoLabel.text = comment.publishDate.toDate().timeAgo()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(100)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteComment(UserDetailViewController.userComments[indexPath.row]._id)
            UserDetailViewController.userComments.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func deleteComment(_ id:String){
        let jsonUrlStr = LoginViewController.serverUrl+"/stickies/"+id
        guard let jsonUrl = URL(string: jsonUrlStr) else {return}
        var request = URLRequest(url:jsonUrl)
        request.httpMethod = "DELETE"
        URLSession.shared.dataTask(with: request){ (data, response, err) in
            //let httpResponse = response as? HTTPURLResponse
            //print(httpResponse!.statusCode)
            if let data = data {
                print("Delete successfully")
            }else{
                print("Delete failed")
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
