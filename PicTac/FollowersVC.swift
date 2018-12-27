//
//  FollowersVC.swift
//  CorkBoard
//
//  Created by Tanner Luke on 10/17/17.
//  Copyright © 2017 CorkBoard Co. All rights reserved.
//

import UIKit
import Parse

var category = String()
var user = String()

class FollowersVC: UITableViewController {
    
    var usernameArray = [String]()
    var profilePicArray = [PFFile]()
    var lockArray = [String]()
    let color = UIColor(displayP3Red: 75/255, green: 239/255, blue: 211/255, alpha: 1)
    let grayColor = UIColor(displayP3Red: 239/255, green: 239/255, blue: 241/255, alpha: 1)
    var followArray = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        networkNotification()
        self.navigationItem.title = category
        if category == "Followers" {
            loadFollowers()
        }
        if category == "Following" {
            loadFollowing()
        }
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
    
    func loadFollowers() {
        let followersQuery = PFQuery(className: "follow")
        followersQuery.whereKey("following", equalTo: user)
        followersQuery.findObjectsInBackground { (objects, error) in
            if error == nil {
                self.followArray.removeAll(keepingCapacity: false)
                
                for object in objects! {
                    self.followArray.append(object.value(forKey: "follower") as! String)
                }
                let query = PFUser.query()
                query?.whereKey("username", containedIn: self.followArray)
                query?.addDescendingOrder("createdAt")
                query?.findObjectsInBackground(block: { (objects, error) in
                    if error == nil {
                        self.usernameArray.removeAll(keepingCapacity: false)
                        self.profilePicArray.removeAll(keepingCapacity: false)
                        for object in objects! {
                            self.usernameArray.append(object.object(forKey: "username") as! String)
                            self.profilePicArray.append(object.object(forKey: "profilepic") as! PFFile)
                            self.lockArray.append(object.object(forKey: "locked") as! String)
                            self.tableView.reloadData()
                        }
                    } else {
                        self.parseErrorAlert()
                        print(error?.localizedDescription ?? "there was an error")
                    }
                })
            } else {
                self.parseErrorAlert()
                print(error?.localizedDescription ?? "there was an error")
            }
        }
    }
    
    func loadFollowing() {
        let followQuery = PFQuery(className: "follow")
        followQuery.whereKey("follower", equalTo: user)
        followQuery.findObjectsInBackground { (objects, error) in
            if error == nil {
                self.followArray.removeAll(keepingCapacity: false)
                for object in objects! {
                    self.followArray.append(object.object(forKey: "following") as! String)
                }
                let query = PFUser.query()
                query?.whereKey("username", containedIn: self.followArray)
                query?.addDescendingOrder("createdAt")
                query?.findObjectsInBackground(block: { (objects, error) in
                    if error == nil {
                        self.usernameArray.removeAll(keepingCapacity: false)
                        self.profilePicArray.removeAll(keepingCapacity: false)
                        for object in objects! {
                            self.usernameArray.append(object.object(forKey: "username") as! String)
                            self.profilePicArray.append(object.object(forKey: "profilepic") as! PFFile)
                            self.tableView.reloadData()                        }
                    } else {
                        self.parseErrorAlert()
                        print(error!.localizedDescription)
                    }
                })
            }
            else {
                self.parseErrorAlert()
                print(error!.localizedDescription)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usernameArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! FollowersCell
        cell.followerUsername.text = usernameArray[indexPath.row]
        profilePicArray[indexPath.row].getDataInBackground { (data, error) in
            if error == nil {
                cell.userProfilePic.image = UIImage(data: data!)
            }
            else{
                self.parseErrorAlert()
                print(error!.localizedDescription)
            }
        }
        let query = PFQuery(className: "follow")
        query.whereKey("follower", equalTo: PFUser.current()!.username!)
        query.whereKey("following", equalTo: cell.followerUsername.text!)
        query.countObjectsInBackground { (count, error) in
            if error == nil {
                if count == 0 {
                    let requestQuery = PFQuery(className: "request")
                    requestQuery.whereKey("follower", equalTo: PFUser.current()!.username!)
                    requestQuery.whereKey("following", equalTo: cell.followerUsername.text!)
                    requestQuery.countObjectsInBackground(block: { (count, error) in
                        if error == nil {
                            if count == 0 {
                                cell.followButton.setTitle("Follow", for: UIControlState())
                                cell.followButton.backgroundColor = .white
                                cell.followButton.setTitleColor(self.color, for: .normal)
                                cell.followButton.layer.borderColor = self.color.cgColor
                                cell.followButton.layer.borderWidth = 1
                            } else {
                                cell.followButton.setTitle("Requested", for: UIControlState.normal)
                                cell.followButton.backgroundColor = self.grayColor
                                cell.followButton.setTitleColor(self.color, for: .normal)
                            }
                        } else {
                            print(error!.localizedDescription)
                            self.parseErrorAlert()
                        }
                    })
                } else {
                    cell.followButton.setTitle("Following", for: UIControlState.normal)
                    cell.followButton.backgroundColor = self.color
                    cell.followButton.setTitleColor(.white, for: UIControlState.normal)
                }
            } else {
                print(error!.localizedDescription)
               
            }
        }
        if cell.followerUsername.text == PFUser.current()?.username {
            cell.followButton.isHidden = true 
        }
        self.tableView.rowHeight = 80
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! FollowersCell
        if cell.followerUsername.text! == PFUser.current()?.username {
            let homeVC = self.storyboard?.instantiateViewController(withIdentifier: "HomePageVC") as! HomePageVC
            self.navigationController?.pushViewController(homeVC, animated: true)
        }
        else {
            friendName.append(cell.followerUsername.text!)
            let friend = self.storyboard?.instantiateViewController(withIdentifier: "FriendProfileVC") as! FriendProfileVC
            self.navigationController?.pushViewController(friend, animated: true)
        }
    }
}

