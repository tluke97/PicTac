//
//  UsersWhoLikedVC.swift
//  CorkBoard
//
//  Created by Tanner Luke on 1/17/18.
//  Copyright © 2018 CorkBoard Co. All rights reserved.
//

import UIKit
import Parse

class UsersWhoLikedVC: UITableViewController {
    
    var findUsersArray = [String]()
    var usernameArray = [String]()
    var profilePicArray = [PFFile]()
    var followArray = [String]()
    var page: Int = 20

    override func viewDidLoad() {
        super.viewDidLoad()
        networkNotification()
        let backButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(UsersWhoLikedVC.back(_:)))
        self.navigationItem.leftBarButtonItem = backButton
        loadUsers()
    }
    
    func networkNotification() {
        if Reachability.isConnectedToNetwork() {
            
            print("connected")
        } else {
            
            let alert = UIAlertController(title: "Network Error", message: "Sorry, but there appears to be an error with your internet connection. Please try again later.", preferredStyle: .alert)
            let okay = UIAlertAction(title: "Okay", style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(okay)
            present(alert, animated: true, completion: nil)
        }
    }
    
    func loadUsers() {
        let userQuery = PFQuery(className: "likes")
        userQuery.whereKey("to", equalTo: postUUID.last!)
        userQuery.findObjectsInBackground { (objects, error) in
            if error == nil {
                self.findUsersArray.removeAll(keepingCapacity: false)
                for object in objects! {
                    self.findUsersArray.append(object.object(forKey: "by") as! String)
                }
                let query = PFQuery(className: "_User")
                query.whereKey("username", containedIn: self.findUsersArray)
                query.limit = self.page
                query.addDescendingOrder("createdAt")
                query.findObjectsInBackground(block: { (objects, error) in
                    if error == nil {
                        self.profilePicArray.removeAll(keepingCapacity: false)
                        self.usernameArray.removeAll(keepingCapacity: false)
                        for object in objects! {
                            self.profilePicArray.append(object.object(forKey: "profilepic") as! PFFile)
                            self.usernameArray.append(object.object(forKey: "username") as! String)
                        }
                         self.tableView.reloadData()
                    }
                })
            }
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height - self.view.frame.size.height * 2 {
            loadMore()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func loadMore() {
        if page <= usernameArray.count {
            page = page + 20
            let userQuery = PFQuery(className: "likes")
            userQuery.whereKey("to", equalTo: postUUID.last!)
            userQuery.findObjectsInBackground { (objects, error) in
                if error == nil {
                    self.findUsersArray.removeAll(keepingCapacity: false)
                    for object in objects! {
                        self.findUsersArray.append(object.object(forKey: "by") as! String)
                    }
                    let query = PFQuery(className: "_User")
                    query.whereKey("username", containedIn: self.findUsersArray)
                    query.limit = self.page
                    query.addDescendingOrder("createdAt")
                    query.findObjectsInBackground(block: { (objects, error) in
                        if error == nil {
                            self.profilePicArray.removeAll(keepingCapacity: false)
                            self.usernameArray.removeAll(keepingCapacity: false)
                            for object in objects! {
                                self.profilePicArray.append(object.object(forKey: "profilepic") as! PFFile)
                                self.usernameArray.append(object.object(forKey: "username") as! String)
                            }
                        }
                    })
                }
            }
            self.tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usernameArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! UsersWhoLikedCell
        cell.username.text = usernameArray[indexPath.row]
        profilePicArray[indexPath.row].getDataInBackground { (data, error) -> Void in
            if error == nil {
                cell.profilePic.image = UIImage(data: data!)
            } else {
                print(error!.localizedDescription)
            }
        }
        let query = PFQuery(className: "follow")
        query.whereKey("follower", equalTo: PFUser.current()!.username!)
        query.whereKey("following", equalTo: cell.username.text!)
        query.countObjectsInBackground { (count, error) in
            if error == nil {
                if count == 0 {
                    let requestQuery = PFQuery(className: "request")
                    requestQuery.whereKey("follower", equalTo: PFUser.current()!.username!)
                    requestQuery.whereKey("following", equalTo: cell.username.text!)
                    requestQuery.countObjectsInBackground(block: { (count, error) in
                        if error == nil {
                            if count == 0 {
                                cell.followButton.setTitle("Follow", for: UIControlState())
                                cell.followButton.backgroundColor = .lightGray
                            } else {
                                cell.followButton.setTitle("Requested", for: UIControlState.normal)
                                cell.followButton.backgroundColor = .red
                            }
                        }
                    })
                } else {
                    cell.followButton.setTitle("Following", for: UIControlState.normal)
                    cell.followButton.backgroundColor = .blue
                    cell.followButton.setTitleColor(.white, for: UIControlState.normal)
                }
            }
        }
        if cell.username.text == PFUser.current()?.username {
            cell.followButton.isHidden = true
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! UsersWhoLikedCell
        if cell.username.text! == PFUser.current()?.username {
           self.performSegue(withIdentifier: "home", sender: self)
        } else {
            friendName.append(cell.username.text!)
            let friend = self.storyboard?.instantiateViewController(withIdentifier: "FriendProfileVC") as! FriendProfileVC
            self.navigationController?.pushViewController(friend, animated: true)
         }
    }
    
    @objc func back(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
}
