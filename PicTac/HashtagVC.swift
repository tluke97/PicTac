//
//  HashtagVC.swift
//  CorkBoard
//
//  Created by Tanner Luke on 11/19/17.
//  Copyright © 2017 CorkBoard Co. All rights reserved.
//

import UIKit
import Parse
import AVFoundation

var hashtag = [String]()

class HashtagVC: UICollectionViewController {
    
    var refresher: UIRefreshControl!
    var page: Int = 24
    var picArray = [PFFile]()
    var uuidArray = [String]()
    var filterArray = [String]()
    var mediaTypeArray = [String]()
    var player = AVPlayer()
    var playerLayer: AVPlayerLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        networkNotification()
        self.collectionView?.alwaysBounceVertical = true
        self.navigationItem.title = "#" + "\(hashtag.last!)"
        self.navigationItem.hidesBackButton = true
        let backButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(HashtagVC.back(_:)))
        self.navigationItem.leftBarButtonItem = backButton
        let backSwipe = UISwipeGestureRecognizer(target: self, action: #selector(HashtagVC.back(_:)))
        backSwipe.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(backSwipe)
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(HomePageVC.refresh), for: UIControlEvents.valueChanged)
        collectionView?.addSubview(refresher)
        let width = UIScreen.main.bounds.width
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        layout.itemSize = CGSize(width: width/4, height: (width/4))
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        collectionView!.collectionViewLayout = layout
        loadHashtag()
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
    
    
    @objc func back(_ sender: UIBarButtonItem) {
        _ = self.navigationController?.popViewController(animated: true)
        if !hashtag.isEmpty {
            hashtag.removeLast()
        }
    }
    
    @objc func refresh() {
        loadHashtag()
    }
    
    func loadHashtag() {
        let hashtagQuery = PFQuery(className: "hashtag")
        hashtagQuery.whereKey("hashtag", equalTo: hashtag.last!)
        hashtagQuery.findObjectsInBackground { (objects, error) in
            if error == nil {
                self.filterArray.removeAll(keepingCapacity: false)
                for object in objects! {
                    self.filterArray.append(object.value(forKey: "to") as! String)
                }
                let query = PFQuery(className: "posts")
                query.whereKey("uuid", containedIn: self.filterArray)
                query.limit = self.page
                query.addDescendingOrder("createdAt")
                query.findObjectsInBackground(block: { (objects, error) in
                    if error == nil {
                        self.mediaTypeArray.removeAll(keepingCapacity: false)
                        self.picArray.removeAll(keepingCapacity: false)
                        self.uuidArray.removeAll(keepingCapacity: false)
                        for object in objects! {
                            self.mediaTypeArray.append(object.value(forKey: "mediatype") as! String)
                            self.picArray.append(object.value(forKey: "media") as! PFFile)
                            self.uuidArray.append(object.value(forKey: "uuid") as! String)
                        }
                        self.collectionView?.reloadData()
                        self.refresher.endRefreshing()
                    } else {
                        self.parseErrorAlert()
                        print(error!.localizedDescription)
                    }
                })
            } else {
                self.parseErrorAlert()
                print(error!.localizedDescription)
            }
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height/3 {
            loadmore()
        }
    }
    
    func loadmore() {
        if page <= uuidArray.count {
            page = page + 15
            let hashtagQuery = PFQuery(className: "hashtag")
            hashtagQuery.whereKey("hashtag", equalTo: hashtag.last!)
            hashtagQuery.findObjectsInBackground { (objects, error) in
                if error == nil {
                    self.filterArray.removeAll(keepingCapacity: false)
                    for object in objects! {
                        self.filterArray.append(object.value(forKey: "to") as! String)
                    }
                    let query = PFQuery(className: "posts")
                    query.whereKey("uuid", containedIn: self.filterArray)
                    query.limit = self.page
                    query.addDescendingOrder("createdAt")
                    query.findObjectsInBackground(block: { (objects, error) in
                        if error == nil {
                            self.picArray.removeAll(keepingCapacity: false)
                            self.uuidArray.removeAll(keepingCapacity: false)
                            for object in objects! {
                                self.picArray.append(object.value(forKey: "media") as! PFFile)
                                self.uuidArray.append(object.value(forKey: "uuid") as! String)
                            }
                            self.collectionView?.reloadData()
                        } else {
                            self.parseErrorAlert()
                            print(error!.localizedDescription)
                        }
                    })
                } else {
                    print(error!.localizedDescription)
                    self.parseErrorAlert()
                }
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return picArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemIndexPath indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: self.view.frame.size.width / 3 , height: self.view.frame.size.width / 3)
        return size
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! pictureCell
        let type = mediaTypeArray[indexPath.row]
        if type == "photo" {
            cell.videoView.isHidden = true
            picArray[indexPath.row].getDataInBackground { (data, error) -> Void in
                if error == nil {
                    cell.pictureImage.image = UIImage(data: data!)
                } else {
                    self.parseErrorAlert()
                    print(error!.localizedDescription)
                }}
        } else if type == "video" {
            cell.videoView.isHidden = false
            var videoUrl: String!
            var videoFile: PFFile
            let videoURL = picArray[indexPath.row].url
            func setupVideoPlayerWithURL(url:NSURL) {
                player = AVPlayer(url: url as URL)
                playerLayer = AVPlayerLayer(player: self.player)
                playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
                playerLayer.frame = cell.videoView.frame
                cell.videoView.layer.addSublayer(self.playerLayer)
            }
            setupVideoPlayerWithURL(url: NSURL(string: videoURL!)!)
        }
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        postUUID = uuidArray
        postAtIndex = indexPath.row
        globalTypeArray = mediaTypeArray
        let post = self.storyboard?.instantiateViewController(withIdentifier: "Post") as! Post
        self.navigationController?.pushViewController(post, animated: true)
    }
}
