//
//  CommentViewController.swift
//  CorkBoard
//
//  Created by Tanner Luke on 11/5/17.
//  Copyright © 2017 CorkBoard Co. All rights reserved.
//

import UIKit
import Parse
import KILabel

var commentuuid = [String]()
var commentowner = [String]()

class CommentViewController: UIViewController, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentInput: UITextView!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var userTable: UITableView!
    @IBOutlet weak var keyboardView: UIView!
    @IBOutlet weak var searchUser: UITextField!
    var refresher = UIRefreshControl()
    var tabBarHeight: CGFloat = 0
    var tableViewHeight: CGFloat = 0
    var commentY: CGFloat = 0
    var commentHeight: CGFloat = 0
    var usernameArray = [String]()
    var profilePicArray = [PFFile]()
    var commentArray = [String]()
    var dateArray = [Date?]()
    var usernameTagArray = [String]()
    var profilePicTagArray = [PFFile]()
    var keyboard = CGRect()
    var page: Int = 15
    let line = UIView()
    let userTableLine = UIView()
    
    var theCommentY: CGFloat!
   
    override func viewDidLoad() {
        networkNotification()
        super.viewDidLoad()
        keyboardView.isHidden = true
        keyboardView.isUserInteractionEnabled = false
        self.navigationItem.title = "Comments"
        self.navigationItem.hidesBackButton = true
        let backButton = UIBarButtonItem(image: #imageLiteral(resourceName: "BackButton.png"), style: .plain, target: self, action: #selector(CommentViewController.back(sender:)))
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = false
        let backSwipe = UISwipeGestureRecognizer(target: self, action: #selector(CommentViewController.back(sender:)))
        backSwipe.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(backSwipe)
        self.userTableLine.backgroundColor = UIColor.lightGray
        
        self.view.addSubview(self.userTableLine)
        userTable.frame.size.width = self.view.frame.size.width
        userTableLine.isHidden = true
        userTable.isHidden = true
        
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(CommentViewController.showKeyboard(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(signUpVC.hideKeyboard(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        postButton.isEnabled = false
        line.backgroundColor = UIColor(displayP3Red: 235/255, green: 235/255, blue: 241/255, alpha: 1)
        self.view.addSubview(line)
        tabBarHeight = self.tabBarController!.tabBar.frame.size.height
        alignment()
        loadComments()
        loadUsers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.navigationBar.isHidden = false
    }
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
        let usersQuery = PFQuery(className: "follow")
        usersQuery.whereKey("follower", equalTo: PFUser.current()!.username!)
        usersQuery.addDescendingOrder("createdAt")
        usersQuery.limit = 20
        usersQuery.findObjectsInBackground { (objects, error) in
            if error == nil {
                self.usernameTagArray.removeAll(keepingCapacity: false)
                for object in objects! {
                    self.usernameTagArray.append(object.value(forKey: "following") as! String)
                    print(self.usernameTagArray)
                    self.userTable.reloadData()
                    self.tableView.reloadData()
                }
            } else {
                self.parseErrorAlert()
                print(error!.localizedDescription)
            }
        }
    }
    
    
    func alignment() {
        self.navigationController?.navigationBar.isHidden = false
        let width = self.view.frame.size.width
        let height = self.view.frame.size.height
        tableView.frame = CGRect(x: 0, y: 0, width: width, height: (height - self.navigationController!.navigationBar.frame.size.height - self.tabBarController!.tabBar.frame.size.height) - UIApplication.shared.statusBarFrame.size.height - 50)   //*0.86
        tableView.estimatedRowHeight = width/5.33333
        tableView.rowHeight = UITableViewAutomaticDimension
        
        if UIApplication.shared.statusBarFrame.height != 20 {
            let difference = UIApplication.shared.statusBarFrame.height - 20
            print("the difference is  \(difference)")
            self.theCommentY = self.navigationController!.navigationBar.frame.size.height + self.tableView.frame.size.height - 35 + difference
        } else {
            self.theCommentY = self.navigationController!.navigationBar.frame.size.height + self.tableView.frame.size.height - 35
        }
        
        
        commentInput.frame = CGRect(x: 10, y: theCommentY  , width: width/1.36, height: 33)
        commentInput.layer.cornerRadius = commentInput.frame.size.width / 50
        postButton.frame = CGRect(x: commentInput.frame.origin.x + commentInput.frame.size.width + width/32, y: commentInput.frame.origin.y, width: width-(commentInput.frame.origin.x + commentInput.frame.size.width)-(width/32)*2, height: commentInput.frame.size.height)
        commentInput.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableViewHeight = tableView.frame.size.height
        commentHeight = commentInput.frame.size.height
        commentY = commentInput.frame.origin.y
        line.frame = CGRect(x: 0, y: commentInput.frame.origin.y - 10, width: self.view.frame.size.width, height: 1)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        print(textView.text)
        
        if textView.text == "" {
            userTable.isHidden = true
            userTableLine.isHidden = true
            usernameTagArray.removeAll(keepingCapacity: false)
        }
        
        let spacing = CharacterSet.whitespacesAndNewlines
        if !commentInput.text.trimmingCharacters(in: spacing).isEmpty {
            postButton.isEnabled = true
        } else {
            postButton.isEnabled = false
        }
        if textView.contentSize.height > textView.frame.size.height && textView.frame.height < 130 {
            let difference = textView.contentSize.height - textView.frame.size.height
            textView.frame.origin.y = textView.frame.origin.y - difference
            textView.frame.size.height = textView.contentSize.height
            self.line.frame.origin.y = textView.frame.origin.y - 10
            userTable.frame = CGRect(x: 10, y: self.commentInput.frame.origin.y - 100 - difference, width: self.commentInput.frame.size.width, height: 100)
            if textView.contentSize.height + keyboard.height + commentY >= tableView.frame.size.height{
                tableView.frame.size.height = tableView.frame.size.height - difference
            }
        }
        else if textView.contentSize.height < textView.frame.size.height {
            let difference = textView.frame.size.height - textView.contentSize.height
            textView.frame.origin.y = textView.frame.origin.y + difference
            textView.frame.size.height = textView.contentSize.height
            self.line.frame.origin.y = textView.frame.origin.y - 10
            if textView.contentSize.height + keyboard.height + commentY > tableView.frame.size.height{
                tableView.frame.size.height = tableView.frame.size.height + difference
            }
        }
        if let typedText = commentInput.text {
           let commentText = typedText
           for character in commentText {
                var characterArray = [Character]()
                characterArray.append(character)
                let typedCharacter = characterArray.last!
                if typedCharacter == "@" {
                    let words: [String] = commentInput.text!.components(separatedBy: NSCharacterSet.whitespacesAndNewlines)
                    for var word in words {
                        if word.hasPrefix("@") {
                            word = word.trimmingCharacters(in: NSCharacterSet.punctuationCharacters)
                            word = word.trimmingCharacters(in: NSCharacterSet.symbols)
                            if usernameArray.contains(word) {
                                userTable.isHidden = true
                                usernameTagArray.removeAll(keepingCapacity: false)
                                userTable.reloadData()
                            }
                            let usersQuery = PFQuery(className: "follow")
                            usersQuery.whereKey("follower", equalTo: PFUser.current()!.username!)
                            usersQuery.whereKey("following", matchesRegex: "(?i)" + word)
                            usersQuery.addDescendingOrder("createdAt")
                            usersQuery.limit = 20
                            usersQuery.findObjectsInBackground { (objects, error) in
                                if error == nil {
                                    self.usernameTagArray.removeAll(keepingCapacity: false)
                                    for object in objects! {
                                        self.usernameTagArray.append(object.value(forKey: "following") as! String)
                                        self.userTable.reloadData()
                                        self.tableView.reloadData()
                                    }
                                } else {
                                    print(error!.localizedDescription)
                                }
                            }
                        }
                    }
                    userTableLine.isHidden = false
                    userTable.isHidden = false
                }
            
                if typedCharacter == " " {
                    userTable.isHidden = true
                    userTableLine.isHidden = true
                    usernameTagArray.removeAll(keepingCapacity: false)
                }
            
            
            }
        }
    }
    
    func loadComments() {
        let countQuery = PFQuery(className: "comments")
        countQuery.whereKey("to", equalTo: commentuuid.last!)
        countQuery.countObjectsInBackground { (count, error) in
            if self.page < count {
                self.refresher.addTarget(self, action: #selector(CommentViewController.loadMore), for: UIControlEvents.valueChanged)
                self.tableView.addSubview(self.refresher)
            }
            let query = PFQuery(className: "comments")
            query.whereKey("to", equalTo: commentuuid.last!)
            let newCount: Int = Int(count)
            query.skip = newCount - self.page
            query.addAscendingOrder("createdAt")
            query.findObjectsInBackground(block: { (objects, error) in
                if error == nil {
                    self.usernameArray.removeAll(keepingCapacity: false)
                    self.profilePicArray.removeAll(keepingCapacity: false)
                    self.commentArray.removeAll(keepingCapacity: false)
                    self.dateArray.removeAll(keepingCapacity: false)
                    for object in objects! {
                        self.usernameArray.append(object.object(forKey: "username") as! String)
                        self.commentArray.append(object.object(forKey: "comment") as! String)
                        self.profilePicArray.append(object.object(forKey: "profilepic") as! PFFile)
                        self.dateArray.append(object.createdAt)
                        self.tableView.reloadData()
                    }
                }
                else {
                    self.parseErrorAlert()
                    print(error!.localizedDescription)
                }
            })
        }
    }
    
    @objc func loadMore() {
        let countQuery = PFQuery(className: "comments")
        countQuery.whereKey("to", equalTo: commentuuid.last!)
        countQuery.countObjectsInBackground { (count, error) in
            if error == nil {
                self.refresher.endRefreshing()
                if self.page >= count {
                    self.refresher.removeFromSuperview()
                }
                if self.page < count {
                    self.page = self.page + 15
                    let query = PFQuery(className: "comments")
                    query.whereKey("to", equalTo: commentuuid.last!)
                    query.skip = (Int(count)) - self.page
                    query.addAscendingOrder("createdAt")
                    query.findObjectsInBackground(block: { (objects, error) in
                        if error == nil {
                            self.usernameArray.removeAll(keepingCapacity: false)
                            self.profilePicArray.removeAll(keepingCapacity: false)
                            self.commentArray.removeAll(keepingCapacity: false)
                            self.dateArray.removeAll(keepingCapacity: false)
                            for object in objects! {
                                self.usernameArray.append(object.object(forKey: "username") as! String)
                                self.commentArray.append(object.object(forKey: "comment") as! String)
                                self.profilePicArray.append(object.object(forKey: "profilepic") as! PFFile)
                                self.dateArray.append(object.createdAt)
                                self.tableView.reloadData()
                            }
                        } else {
                            self.parseErrorAlert()
                            print(error!.localizedDescription)
                        }
                    })
                }
            } else {
                self.parseErrorAlert()
                print(error!.localizedDescription)
            }
        }
    }
    
    
    
    
    func pushCommentNotification1(username: String) {
        
        let notificationTo = PFQuery(className: "_User")
        notificationTo.whereKey("username", equalTo: username)
        notificationTo.findObjectsInBackground { (objects, error) in
            if error == nil {
                print(objects!)
                for object in objects! {
                    let sendingTo = object.objectId!
                    let text = "\(PFUser.current()!.username!) followed you, or whatever you want to say here";
                    let data = [
                        "badge" : "Increment",
                        "alert" : text,
                        ]
                    let request: [String : Any] = [
                        "likeFrom" : PFUser.current()!.username!,
                        "data" : data,
                        "sendTo" : sendingTo
                    ]
                    //let cloudParams : [AnyHashable:String] = [:]
                    PFCloud.callFunction(inBackground: "commentPush", withParameters: request as [NSObject : AnyObject], block: {
                        (result: Any?, error: Error?) -> Void in
                        if error != nil {
                            if let descrip = error?.localizedDescription{
                                print(descrip)
                            }
                        }else{
                            print(result as! String)
                        }
                    })
                }
            } else {
                print(error!.localizedDescription)
            }
        }
        
    }
    
    
    
    
    
    @IBAction func postButtonClick(_ sender: Any) {
        networkNotification()
        userTable.isHidden = true
        usernameArray.append(PFUser.current()!.username!)
        profilePicArray.append(PFUser.current()?.object(forKey: "profilepic") as! PFFile)
        dateArray.append(Date())
        commentArray.append(commentInput.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
        tableView.reloadData()
        let commentObject = PFObject(className: "comments")
        commentObject["to"] = commentuuid.last
        commentObject["username"] = PFUser.current()?.username
        commentObject["profilepic"] = PFUser.current()?.object(forKey: "profilepic")
        commentObject["comment"] = commentInput.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        commentObject.saveInBackground { (success, error) in
            if error == nil {
                
                let query = PFQuery(className: "posts")
                query.whereKey("uuid", equalTo: commentuuid.last!)
                query.findObjectsInBackground(block: { (objects, error) in
                    if error == nil {
                        for object in objects! {
                            let username = object.object(forKey: "username") as! String
                            let notification = PushNotifications()
                            print(username)
                            notification.pushCommentNotification(username: username)
                            //self.pushCommentNotification1(username: username)
                            
                        }
                    }
                })
                
                
                
                
            } else {
                print(error!.localizedDescription)
                self.parseErrorAlert()
            }
        }
        let words: [String] = commentInput.text!.components(separatedBy: NSCharacterSet.whitespacesAndNewlines)
        for var word in words {
            if word.hasPrefix("#") {
                word = word.trimmingCharacters(in: NSCharacterSet.punctuationCharacters)
                word = word.trimmingCharacters(in: NSCharacterSet.symbols)
                let hashtagObject = PFObject(className: "hashtag")
                hashtagObject["to"] = commentuuid.last
                hashtagObject["by"] = PFUser.current()?.username
                hashtagObject["hashtag"] = word.lowercased()
                hashtagObject["comment"] = commentInput.text
                hashtagObject.saveInBackground(block: { (success, error) in
                    if error == nil {
                        print("#\(word) created")
                    }
                    else {
                        self.parseErrorAlert()
                        print(error!.localizedDescription)
                    }
                })
            }
        }
        var mentionCreated = Bool()
        for var word in words {
            if word.hasPrefix("@") {
                word = word.trimmingCharacters(in: CharacterSet.punctuationCharacters)
                word = word.trimmingCharacters(in: CharacterSet.symbols)
                let notificationObject = PFObject(className: "notification")
                notificationObject["by"] = PFUser.current()?.username
                 notificationObject["profilepic"] = PFUser.current()?.object(forKey: "profilepic") as! PFFile
                notificationObject["to"] = word
                notificationObject["owner"] = commentowner.last
                notificationObject["uuid"] = commentuuid.last
                notificationObject["type"] = "mention"
                notificationObject["checked"] = "no"
                notificationObject.saveEventually()
                mentionCreated = true
            }
        }
        if commentowner.last != PFUser.current()?.username && mentionCreated == false {
            let notificationObject = PFObject(className: "notification")
            notificationObject["by"] = PFUser.current()?.username
            notificationObject["profilepic"] = PFUser.current()?.object(forKey: "profilepic") as! PFFile
            notificationObject["to"] = commentowner.last
            notificationObject["owner"] = commentowner.last
            notificationObject["uuid"] = commentuuid.last
            notificationObject["type"] = "comment"
            notificationObject["checked"] = "no"
            notificationObject.saveEventually()
        }
        self.tableView.scrollToRow(at: IndexPath(item: commentArray.count - 1, section: 0), at: UITableViewScrollPosition.bottom, animated: false)
        postButton.isEnabled = false
        commentInput.text = ""
        self.view.endEditing(true)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView {
        return commentArray.count
        } else {
            return usernameTagArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.tableView {
        return UITableViewAutomaticDimension
        } else {
            return 70
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell: UITableViewCell?
        if tableView == self.tableView {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! CommentTableViewCell
            cell.usernameButton.setTitle(usernameArray[indexPath.row], for: UIControlState.normal)
            cell.usernameButton.sizeToFit()
            cell.commentText?.text = commentArray[indexPath.row]
            profilePicArray[indexPath.row].getDataInBackground { (data, error) in
                if error == nil {
                    cell.profilePic.image = UIImage(data: data!)
                }
                else {
                    self.parseErrorAlert()
                    print(error!.localizedDescription)
                }
            }
            let from = dateArray[indexPath.row]
            let now = Date()
            let components : NSCalendar.Unit = [.second, .minute, .hour, .day, .weekOfMonth]
            let difference = (Calendar.current as NSCalendar).components(components, from: from!, to: now, options: [])
            if difference.second! <= 0 {
                cell.timeLabel.text = "now"
            }
            if difference.second! > 0 && difference.minute! == 0 {
                cell.timeLabel.text = "\(difference.second!)s"
            }
            if difference.minute! > 0 && difference.hour! == 0 {
                cell.timeLabel.text = "\(difference.minute!)m"
            }
            if difference.hour! > 0 && difference.day! == 0 {
                cell.timeLabel.text = "\(difference.hour!)h"
            }
            if difference.day! > 0 && difference.weekOfMonth! == 0 {
                cell.timeLabel.text = "\(difference.day!)d"
            }
            if difference.weekOfMonth! > 0 {
                cell.timeLabel.text = "\(difference.weekOfMonth!)w"
            }
            cell.commentText.userHandleLinkTapHandler = { label, handle, range in
                var mention = handle
                mention = String(mention.dropFirst())
                if mention == PFUser.current()?.username {
                    let home = self.storyboard?.instantiateViewController(withIdentifier: "HomePageVC") as! HomePageVC
                    self.navigationController?.pushViewController(home, animated: true)
                } else {
                    friendName.append(mention)
                    let guest = self.storyboard?.instantiateViewController(withIdentifier: "FriendProfileVC") as! FriendProfileVC
                    self.navigationController?.pushViewController(guest, animated: true)
                }
            }
            cell.commentText.hashtagLinkTapHandler = { label, handle, range in
                var mention = handle
                mention = String(mention.dropFirst())
                hashtag.append(mention.lowercased())
                let theHashtag = self.storyboard?.instantiateViewController(withIdentifier: "HashtagVC") as! HashtagVC
                self.navigationController?.pushViewController(theHashtag, animated: true)
            }
            cell.usernameButton.layer.setValue(indexPath, forKey: "index")
            return cell
        } else {
           // if tableView == self.userTable {
                let cell = tableView.dequeueReusableCell(withIdentifier: "UsernameCell") as! UsernameCell
                cell.username.text = usernameTagArray[indexPath.row]
                return cell
                //}
            }
        
       // return cell!
    }
    
    @IBAction func usernameButtonClicked(_ sender: AnyObject) {
        let i = sender.layer.value(forKey: "index") as! IndexPath
        let cell = tableView.cellForRow(at: i) as! CommentTableViewCell
        if cell.usernameButton.titleLabel?.text == PFUser.current()?.username {
            let home = self.storyboard?.instantiateViewController(withIdentifier: "HomePageVC") as! HomePageVC
            self.navigationController?.pushViewController(home, animated: true)
        } else {
            friendName.append(cell.usernameButton.titleLabel!.text!)
            let friend = self.storyboard?.instantiateViewController(withIdentifier: "FriendProfileVC") as! FriendProfileVC
            self.navigationController?.pushViewController(friend, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let cell = tableView.cellForRow(at: indexPath) as! CommentTableViewCell
        let delete = UITableViewRowAction(style: UITableViewRowActionStyle.normal, title: "1") { (action, indexPath) in
            let commentQuery = PFQuery(className: "comments")
            commentQuery.whereKey("to", equalTo: commentuuid.last!)
            commentQuery.whereKey("comment", equalTo: cell.commentText!.text!)
            commentQuery.findObjectsInBackground(block: { (objects, error) in
                if error == nil {
                    for object in objects! {
                        object.deleteEventually()
                    }
                }
                else {
                    self.parseErrorAlert()
                    print(error!.localizedDescription)
                }
            })
            let hashtagQuery = PFQuery(className: "hashtag")
            hashtagQuery.whereKey("to", equalTo: commentuuid.last!)
            hashtagQuery.whereKey("by", equalTo: cell.usernameButton.titleLabel!.text!)
            hashtagQuery.whereKey("comment", equalTo: cell.commentText.text!)
            hashtagQuery.findObjectsInBackground(block: { (objects, error) in
                if error == nil {
                    for object in objects! {
                        object.deleteEventually()
                    }
                }
            })
            let notificationQuery = PFQuery(className: "notification")
            notificationQuery.whereKey("to", equalTo: cell.usernameButton.titleLabel!.text!)
            notificationQuery.whereKey("by", equalTo: commentowner.last!)
            notificationQuery.whereKey("uuid", equalTo: commentuuid.last!)
            notificationQuery.whereKey("type", containedIn: ["comment", "mention"])
            notificationQuery.findObjectsInBackground(block: { (objects, error) in
                if error == nil {
                    for object in objects! {
                        object.deleteEventually()
                    }
                }
            })
            self.commentArray.remove(at: indexPath.row)
            self.dateArray.remove(at: indexPath.row)
            self.usernameArray.remove(at: indexPath.row)
            self.profilePicArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
        }
        let complain = UITableViewRowAction(style: UITableViewRowActionStyle.normal, title: "2") { (action, indexPath) in
            let complainObj = PFObject(className: "complain")
            complainObj["by"] = PFUser.current()?.username
            complainObj["post"] = commentuuid.last!
            complainObj["to"] = cell.commentText?.text
            complainObj["owner"] = cell.usernameButton.titleLabel?.text
            complainObj.saveInBackground(block: { (success, error) in
                if error == nil {
                    self.alert(title: "Complaint Has Been Filed", message: "We have successfully recieved your complaint and will review the post as soon as we can. We thank you for your patience.")
                } else {
                    self.alert(title: "Error", message: error!.localizedDescription)
                }
            })
            tableView.setEditing(false, animated: true)
        }
        delete.backgroundColor = UIColor.red
        complain.backgroundColor = UIColor.yellow
        if cell.usernameButton.titleLabel?.text == PFUser.current()?.username {
            return[delete]
        } else if commentowner.last == PFUser.current()?.username {
            return [delete, complain]
        } else {
            return [complain]
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! UsernameCell
        let replacement = " @\(cell.username.text!)"
        if let typedText = commentInput.text {
            print(typedText)
            var words: [String] = commentInput.text!.components(separatedBy: NSCharacterSet.whitespacesAndNewlines)
            for var word in words {
                if word.hasPrefix("@") {
                    let chosenWord = word
                    let index = words.index(of: chosenWord)
                    word = word.trimmingCharacters(in: NSCharacterSet.punctuationCharacters)
                    word = word.trimmingCharacters(in: NSCharacterSet.symbols)
                    if usernameTagArray.contains(word) == false {
                        words.remove(at: index!)
                        let newString = words.joined(separator: " ")
                        commentInput.text = newString
                    }
                }
            }
        }
        /*
        if let selectedRange = commentInput.selectedTextRange {
            //let cursorPosition = commentInput.offset(from: commentInput.beginningOfDocument, to: selectedRange.start)
            //let wordIndex = IndexPath(item: cursorPosition, section: 0)
        }
        */
        commentInput.insertText(replacement)
        userTable.isHidden = true
        userTableLine.isHidden = true
        usernameTagArray.removeAll(keepingCapacity: false)
        userTable.reloadData()
    }
    
    func alert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    @objc func back(sender: UIBarButtonItem) {
        self.commentHeight = 0
        self.commentY = 0
        self.commentInput.frame.size.height = 0
        self.navigationController?.popViewController(animated: true)
        if !commentuuid.isEmpty {
            commentuuid.removeLast()
        }
        if !commentowner.isEmpty {
            commentowner.removeLast()
        }
    }
    
    @objc func showKeyboard(notification: NSNotification) {
        keyboard = ((notification.userInfo?[UIKeyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue)!
        UIView.animate(withDuration: 0.4) {
            let height: CGFloat = self.keyboard.height + self.commentHeight + self.commentInput.frame.size.height - (self.commentInput.frame.size.height*2) - self.tabBarHeight
            self.tableView.frame.size.height = self.tableViewHeight - height
            if UIApplication.shared.statusBarFrame.height != 20 {
                let difference = UIApplication.shared.statusBarFrame.height - 20
                print("the difference is  \(difference)")
                self.commentInput.frame.origin.y = self.commentY - self.keyboard.height - self.commentInput.frame.size.height + self.commentHeight + self.tabBarHeight + difference
            } else {
                self.commentInput.frame.origin.y = self.commentY - self.keyboard.height - self.commentInput.frame.size.height + self.commentHeight + self.tabBarHeight
            }
            self.line.frame.origin.y = self.commentInput.frame.origin.y - 10
            self.postButton.frame.origin.y = self.commentInput.frame.origin.y
            
            //self.userTable.frame = CGRect(x: 10, y: self.commentInput.frame.origin.y - 100, width: self.view.frame.size.width, height: 150)
        }
        let tapToHide = UITapGestureRecognizer(target: self, action: #selector(CommentViewController.hideKeyboardTap(recognizer:)))
        self.keyboardView.isHidden = false
        self.keyboardView.isUserInteractionEnabled = true
        self.keyboardView.addGestureRecognizer(tapToHide)
        self.keyboardView.frame.size.height = self.view.frame.size.height - 65 - self.keyboard.height - 80
        let theY = self.view.frame.size.height - 65 - self.keyboard.height - 80
        self.keyboardView.frame.origin.y = self.view.frame.size.height - self.keyboard.height - 65 - theY
        self.keyboardView.frame.size.width = self.view.frame.size.width
        self.userTable.frame = self.keyboardView.frame
        
        
        self.userTableLine.frame = CGRect(x: 0, y: self.userTable.frame.origin.y, width: self.view.frame.size.width, height: 1)
       
        
    }
    
    @objc func hideKeyboard(notification: NSNotification) {
        UIView.animate(withDuration: 0.4) {
            self.tableView.frame.size.height = self.tableViewHeight
            self.commentInput.frame.origin.y = self.commentY
            self.postButton.frame.origin.y = self.commentY
            self.line.frame.origin.y = self.commentY - 10
        }
        self.keyboardView.isHidden = true
        self.keyboardView.isUserInteractionEnabled = false
    }
    
    @objc func hideKeyboardTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
}
