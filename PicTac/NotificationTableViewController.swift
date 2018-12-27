 //
//  NotificationTableViewController.swift
//  CorkBoard
//
//  Created by Tanner Luke on 12/19/17.
//  Copyright © 2017 CorkBoard Co. All rights reserved.
//

import UIKit
import Parse
 
 var goToComment: Bool = false

class NotificationTableViewController: UITableViewController {

    var refresher = UIRefreshControl()
    var usernameArray = [String]()
    var profilePicArray = [PFFile]()
    var typeArray = [String]()
    var dateArray = [Date?]()
    var uuidArray = [String]()
    var ownerArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        networkNotification()
        tableView.rowHeight = 70
        refresher.addTarget(self, action: #selector(NotificationTableViewController.reload)  , for: UIControlEvents.valueChanged)
        self.tableView.addSubview(refresher)
        self.navigationItem.title = "Notifications"
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = false
        NotificationCenter.default.addObserver(self, selector: #selector(NotificationTableViewController.reloadTableCell), name: NSNotification.Name("reloadTableCell"), object: nil)
        loadNotifications()
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usernameArray.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if typeArray[indexPath.row] == "request" {
            return 110
        } else {
            return 70
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if typeArray[indexPath.row] == "request" {
            let requestCell = tableView.dequeueReusableCell(withIdentifier: "RequestCell") as! RequestCell
            requestCell.username.setTitle(usernameArray[indexPath.row], for: UIControlState.normal)
            profilePicArray[indexPath.row].getDataInBackground { (data, error) in
                if error == nil {
                    requestCell.profilePic.image = UIImage(data: data!)
                } else {
                    self.parseErrorAlert()
                    print(error!.localizedDescription)
                }
            }
            let from = dateArray[indexPath.row]
            let now = Date()
            let components : NSCalendar.Unit = [.second, .minute, .hour, .day, .weekOfMonth]
            let difference = (Calendar.current as NSCalendar).components(components, from: from!, to: now, options: [])
            if difference.second! <= 0 {
                requestCell.date.text = "now"
            }
            if difference.second! > 0 && difference.minute! == 0 {
                requestCell.date.text = "\(difference.second!)s"
            }
            if difference.minute! > 0 && difference.hour! == 0 {
                requestCell.date.text = "\(difference.minute!)m"
            }
            if difference.hour! > 0 && difference.day! == 0 {
                requestCell.date.text = "\(difference.hour!)h"
            }
            if difference.day! > 0 && difference.weekOfMonth! == 0 {
                requestCell.date.text = "\(difference.day!)d"
            }
            if difference.weekOfMonth! > 0 {
                requestCell.date.text = "\(difference.weekOfMonth!)w"
            }
            if typeArray[indexPath.row] == "request" {
                requestCell.info.text = "has requested to follow you"
            }
            requestCell.username.layer.setValue(indexPath, forKey: "index")
            return requestCell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! NotificationCell
            cell.username.setTitle(usernameArray[indexPath.row], for: UIControlState.normal)
            profilePicArray[indexPath.row].getDataInBackground { (data, error) in
                if error == nil {
                    cell.profilePic.image = UIImage(data: data!)
                } else {
                    self.parseErrorAlert()
                    print(error!.localizedDescription)
                }
            }
            let from = dateArray[indexPath.row]
            let now = Date()
            let components : NSCalendar.Unit = [.second, .minute, .hour, .day, .weekOfMonth]
            let difference = (Calendar.current as NSCalendar).components(components, from: from!, to: now, options: [])
            if difference.second! <= 0 {
                cell.date.text = "now"
            }
            if difference.second! > 0 && difference.minute! == 0 {
                cell.date.text = "\(difference.second!)s"
            }
            if difference.minute! > 0 && difference.hour! == 0 {
                cell.date.text = "\(difference.minute!)m"
            }
            if difference.hour! > 0 && difference.day! == 0 {
                cell.date.text = "\(difference.hour!)h"
            }
            if difference.day! > 0 && difference.weekOfMonth! == 0 {
                cell.date.text = "\(difference.day!)d"
            }
            if difference.weekOfMonth! > 0 {
                cell.date.text = "\(difference.weekOfMonth!)w"
            }
            if typeArray[indexPath.row] == "mention" {
                cell.info.text = "tagged you in a post"
            }
            if typeArray[indexPath.row] == "comment" {
                cell.info.text = "commented on your post"
            }
            if typeArray[indexPath.row] == "follow" {
                cell.info.text = "has followed you"
            }
            if typeArray[indexPath.row] == "like" {
                cell.info.text = "has liked your post"
                
            }
            if typeArray[indexPath.row] == "request" {
                cell.info.text = "has requested to follow you"
            }
            if typeArray[indexPath.row] == "screenshot" {
                
                cell.info.text = "took a screenshot"
            }
            cell.username.layer.setValue(indexPath, forKey: "index")
            cell.info.sizeToFit()
            cell.username.sizeToFit()
            return cell
        }
    }
    
    func networkNotification() {
        if Reachability.isConnectedToNetwork() {
            
            print("connected")
        } else {
            self.refresher.endRefreshing()
            let alert = UIAlertController(title: "Network Error", message: "Sorry, but there appears to be an error with your internet connection. Please try again later.", preferredStyle: .alert)
            let okay = UIAlertAction(title: "Okay", style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(okay)
            present(alert, animated: true, completion: nil)
        }
    }
    
    func loadNotifications() {
        let query = PFQuery(className: "notification")
        query.whereKey("to", equalTo: PFUser.current()!.username!)
        query.limit = 30
        query.addDescendingOrder("createdAt")
        query.findObjectsInBackground { (objects, error) in
            if error == nil {
                self.usernameArray.removeAll(keepingCapacity: false)
                self.profilePicArray.removeAll(keepingCapacity: false)
                self.typeArray.removeAll(keepingCapacity: false)
                self.dateArray.removeAll(keepingCapacity: false)
                self.uuidArray.removeAll(keepingCapacity: false)
                self.ownerArray.removeAll(keepingCapacity: false)
                for object in objects! {
                    self.usernameArray.append(object.object(forKey: "by") as! String)
                    self.profilePicArray.append(object.object(forKey: "profilepic") as! PFFile)
                    self.typeArray.append(object.object(forKey: "type") as! String)
                    self.dateArray.append(object.createdAt)
                    self.uuidArray.append(object.object(forKey: "uuid") as! String)
                    self.ownerArray.append(object.object(forKey: "owner") as! String)
                    UIView.animate(withDuration: 1, animations: {
                        dot.alpha = 0
                    })
                    object["checked"] = "yes"
                    object.saveEventually()
                }
                self.tableView.reloadData()
            } else {
                self.parseErrorAlert()
                print(error!.localizedDescription)
            }
        }
    }
    
    @objc func reloadTableCell() {
        
        self.tableView.reloadData()
        
        
    }
    
    @IBAction func usernameClick(_ sender: AnyObject) {
        let i = sender.layer.value(forKey: "index") as! IndexPath
        let cell = tableView.cellForRow(at: i) as! NotificationCell
        if cell.username.titleLabel?.text == PFUser.current()?.username {
            let home = self.storyboard?.instantiateViewController(withIdentifier: "HomePageVC") as! HomePageVC
            self.navigationController?.pushViewController(home, animated: true)
        } else {
            friendName.append(cell.username.titleLabel!.text!)
            let friend = self.storyboard?.instantiateViewController(withIdentifier: "FriendProfileVC") as! FriendProfileVC
            self.navigationController?.pushViewController(friend, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! NotificationCell
        if cell.info.text == "has requested to follow you" {
            friendName.append(cell.username.titleLabel!.text!)
            let friend = self.storyboard?.instantiateViewController(withIdentifier: "FriendProfileVC") as! FriendProfileVC
            self.navigationController?.pushViewController(friend, animated: true)
        }
        if cell.info.text == "tagged you in a post" {
            postUUID.append(uuidArray[indexPath.row])
            postAtIndex = 0 
            let post = self.storyboard?.instantiateViewController(withIdentifier: "Post") as! Post
            self.navigationController?.pushViewController(post, animated: true)
        }
        if cell.info.text == "commented on your post" {
            postUUID.append(uuidArray[indexPath.row])
            postAtIndex = 0
            let post = self.storyboard?.instantiateViewController(withIdentifier: "Post") as! Post
            goToComment = true
            self.navigationController?.pushViewController(post, animated: true)
        }
        if cell.info.text == "has followed you" {
            friendName.append(cell.username.titleLabel!.text!)
            let friend = self.storyboard?.instantiateViewController(withIdentifier: "FriendProfileVC") as! FriendProfileVC
            self.navigationController?.pushViewController(friend, animated: true)
        }
        if cell.info.text == "has liked your post" {
            postUUID.append(uuidArray[indexPath.row])
            postAtIndex = 0
            let post = self.storyboard?.instantiateViewController(withIdentifier: "Post") as! Post
            self.navigationController?.pushViewController(post, animated: true)
        }
        if cell.info.text == "took a screenshot" {
            postUUID.append(uuidArray[indexPath.row])
            postAtIndex = 0
            let post = self.storyboard?.instantiateViewController(withIdentifier: "Post") as! Post
            self.navigationController?.pushViewController(post, animated: true)
        }
    }
    
    @IBAction func followButton(_ sender: AnyObject) {
        let buttonPosition = sender.convert(CGPoint.zero, to: tableView)
        let indexPath: IndexPath! = tableView.indexPathForRow(at: buttonPosition)
        let cell = self.tableView.cellForRow(at: indexPath!) as! NotificationCell
        let requestQuery = PFQuery(className: "request")
        requestQuery.whereKey("following", equalTo: PFUser.current()!.username!)
        requestQuery.whereKey("follower", equalTo: cell.username.titleLabel!.text!)
        requestQuery.findObjectsInBackground(block: { (objects, error) in
            if error == nil {
                for object in objects! {
                    object.deleteEventually()
                }
            } else {
                print(error!.localizedDescription)
                self.parseErrorAlert()
            }
        })
    }
    
    @IBAction func ignoreButton(_ sender: AnyObject) {
        let buttonPosition = sender.convert(CGPoint.zero, to: tableView)
        let indexPath: IndexPath! = tableView.indexPathForRow(at: buttonPosition)
        let cell = self.tableView.cellForRow(at: indexPath!) as! NotificationCell
        let requestQuery = PFQuery(className: "request")
        requestQuery.whereKey("following", equalTo: PFUser.current()!.username!)
        requestQuery.whereKey("follower", equalTo: cell.username.titleLabel!.text!)
        requestQuery.findObjectsInBackground(block: { (objects, error) in
            if error == nil {
                for object in objects! {
                    object.deleteEventually()
                }
            } else {
                print(error!.localizedDescription)
                self.parseErrorAlert()
            }
        })
    }
    
    @objc func reload() {
        networkNotification()
        self.tableView.reloadData()
        loadNotifications()
        refresher.endRefreshing()
    }
}
