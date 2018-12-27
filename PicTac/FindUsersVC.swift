//
//  FindUsersVC.swift
//  CorkBoard
//
//  Created by Tanner Luke on 12/8/17.
//  Copyright © 2017 CorkBoard Co. All rights reserved.
//

import UIKit
import Parse
import AVFoundation

class FindUsersVC: UITableViewController, UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var searchBar = UISearchBar()
    var usernameArray = [String]()
    var profilePicArray = [PFFile]()
    var collectionView: UICollectionView!
    var picArray = [PFFile]()
    var uuidArray = [String]()
    var mediaTypeArray = [String]()
    var player = AVPlayer()
    var playerLayer: AVPlayerLayer!
    var page: Int = 24
    

    override func viewDidLoad() {
        super.viewDidLoad()
        networkNotification()
        searchBar.delegate = self
        searchBar.sizeToFit()
        searchBar.tintColor = UIColor.groupTableViewBackground
        searchBar.frame.size.width = self.view.frame.size.width - 34
        let searchItem = UIBarButtonItem(customView: searchBar)
        self.navigationItem.leftBarButtonItem = searchItem
        loadUsers()
        collectionViewLaunch()
    }
    
    func loadUsers() {
        let usersQuery = PFQuery(className: "_User")
        usersQuery.addDescendingOrder("createdAt")
        usersQuery.limit = 20
        usersQuery.findObjectsInBackground { (objects, error) in
            if error == nil {
                self.usernameArray.removeAll(keepingCapacity: false)
                self.profilePicArray.removeAll(keepingCapacity: false)
                for object in objects! {
                    self.usernameArray.append(object.value(forKey: "username") as! String)
                    self.profilePicArray.append(object.value(forKey: "profilepic") as! PFFile)
                }
                self.tableView.reloadData()
            } else {
                self.parseErrorAlert()
                print(error!.localizedDescription)
            }
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
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let usernameQuery = PFQuery(className: "_User")
        usernameQuery.whereKey("username", matchesRegex: "(?i)" + searchBar.text!)
        usernameQuery.findObjectsInBackground { (objects, error) in
            if error == nil {
                if objects!.isEmpty {
                    let fullnameQuery = PFUser.query()
                    fullnameQuery?.whereKey("fullname", matchesRegex: "(?i)" + searchBar.text!)
                    fullnameQuery?.findObjectsInBackground(block: { (objects, error) in
                        if error == nil {
                            self.usernameArray.removeAll(keepingCapacity: false)
                            self.profilePicArray.removeAll(keepingCapacity: false)
                            for object in objects! {
                                self.usernameArray.append(object.value(forKey: "username") as! String)
                                self.profilePicArray.append(object.value(forKey: "profilepic") as! PFFile)
                            }
                            self.tableView.reloadData()
                        } else {
                            self.parseErrorAlert()
                            print(error!.localizedDescription)
                        }
                    })
                }
                self.usernameArray.removeAll(keepingCapacity: false)
                self.profilePicArray.removeAll(keepingCapacity: false)
                for object in objects! {
                    self.usernameArray.append(object.value(forKey: "username") as! String)
                    self.profilePicArray.append(object.value(forKey: "profilepic") as! PFFile)
                }
                self.tableView.reloadData()
            } else {
                self.parseErrorAlert()
                print(error!.localizedDescription)
            }
        }
        return true
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        collectionView.isHidden = true
        searchBar.showsCancelButton = true
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        collectionView.isHidden = false
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
        searchBar.text = ""
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usernameArray.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! FollowersCell
        cell.followButton.isHidden = true
        cell.followerUsername.text = usernameArray[indexPath.row]
        profilePicArray[indexPath.row].getDataInBackground { (data, error) in
            if error == nil {
                cell.userProfilePic.image = UIImage(data: data!)
            } else {
                self.parseErrorAlert()
                print(error!.localizedDescription)
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! FollowersCell
        if cell.followerUsername.text! == PFUser.current()?.username! {
            let home = self.storyboard?.instantiateViewController(withIdentifier: "HomePageVC") as! HomePageVC
            self.navigationController?.pushViewController(home, animated: true)
        } else {
            friendName.append(cell.followerUsername.text!)
            let friend = self.storyboard?.instantiateViewController(withIdentifier: "FriendProfileVC") as! FriendProfileVC
            self.navigationController?.pushViewController(friend, animated: true)
        }
    }
    
    func collectionViewLaunch() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: (self.view.frame.size.width/4)-1, height: (self.view.frame.size.width/4)-1)
       
        layout.scrollDirection = UICollectionViewScrollDirection.vertical
        let frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height - self.tabBarController!.tabBar.frame.size.height - self.navigationController!.navigationBar.frame.size.height - UIApplication.shared.statusBarFrame.height)
        collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .white
        self.view.addSubview(collectionView)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        loadPosts()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: (self.view.frame.size.width/4)-1, height: (self.view.frame.size.width/4)-1)
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return picArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        let picImage = UIImageView(frame: CGRect(x: 0, y: 0, width: cell.frame.size.width, height: cell.frame.size.height))
        picImage.contentMode = .scaleAspectFill
        picImage.layer.masksToBounds = true
        let videoView = UIView(frame: CGRect(x: 0, y: 0, width: cell.frame.size.width, height: cell.frame.size.height))
        cell.addSubview(videoView)
        cell.addSubview(picImage)
        
        let type = mediaTypeArray[indexPath.row]
        if type == "photo" {
            videoView.isHidden = true
            picArray[indexPath.row].getDataInBackground { (data, error) -> Void in
                if error == nil {
                    
                    
                    picImage.image = UIImage(data: data!)
                } else {
                    self.parseErrorAlert()
                    print(error!.localizedDescription)
                }}
        } else if type == "video" {
            picImage.isHidden = true
            videoView.isHidden = false
            var videoUrl: String!
            var videoFile: PFFile
            let videoURL = picArray[indexPath.row].url
            func setupVideoPlayerWithURL(url:NSURL) {
                player = AVPlayer(url: url as URL)
                playerLayer = AVPlayerLayer(player: self.player)
                playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
                playerLayer.frame = videoView.frame
                videoView.layer.addSublayer(self.playerLayer)
            }
            setupVideoPlayerWithURL(url: NSURL(string: videoURL!)!)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        postUUID = uuidArray
        postAtIndex = indexPath.row
        globalTypeArray = mediaTypeArray
        let post = self.storyboard?.instantiateViewController(withIdentifier: "Post") as! Post
        self.navigationController?.pushViewController(post, animated: true)
    }
    
    @objc func loadPosts() {
        let query = PFQuery(className: "posts")
        query.whereKey("lock", equalTo: "no")
        query.limit = page
        query.addDescendingOrder("createdAt")
        query.findObjectsInBackground { (objects, error) in
            if error == nil {
                self.mediaTypeArray.removeAll(keepingCapacity: false)
                self.picArray.removeAll(keepingCapacity: false)
                self.uuidArray.removeAll(keepingCapacity: false)
                for object in objects! {
                    self.mediaTypeArray.append(object.object(forKey: "mediatype") as! String)
                    self.picArray.append(object.object(forKey: "media") as! PFFile)
                    self.uuidArray.append(object.object(forKey: "uuid") as! String)
                }
                self.collectionView.reloadData()
            } else {
                self.parseErrorAlert()
                print(error!.localizedDescription)
            }
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > scrollView.contentSize.height / 6 {
            self.loadmore()
        }
    }
    
    func loadmore() {
        if page <= picArray.count {
            page = page + 24
            let query = PFQuery(className: "posts")
            query.limit = page
            query.findObjectsInBackground(block: { (objects, error) in
                if error == nil {
                    self.picArray.removeAll(keepingCapacity: false)
                    self.uuidArray.removeAll(keepingCapacity: false)
                    for object in objects!  {
                        self.picArray.append(object.object(forKey: "pic") as! PFFile)
                        self.uuidArray.append(object.object(forKey: "uuid") as! String)
                    }
                    self.collectionView.reloadData()
                } else {
                    self.parseErrorAlert()
                    print(error!.localizedDescription)
                }
            })
        }
    }
}
