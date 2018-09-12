//
//  PhotosViewController.swift
//  Tumblr
//
//  Created by Pann Cherry on 9/6/18.
//  Copyright © 2018 Pann Cherry. All rights reserved.
//

import UIKit
import AlamofireImage

class PhotosViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    
    var posts: [[String: Any]] = []
    var refreshControl: UIRefreshControl!
    var isMoreDataLoading = false

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(PhotosViewController.didPullToRefresh(_:)), for: UIControlEvents.valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 275
        fetchPhotos()
        }
    
    //code to fetch photos when pull to refresh
    @objc func didPullToRefresh(_ refreshControl: UIRefreshControl) {
        fetchPhotos()
    }
    
    //code to get photo counts
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    //code to get the photo and display
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        let post = posts[indexPath.row]
        if let photos = post["photos"] as? [[String: Any]]{
           // photoImageView = UIImageView(frame: frame)
            let photo = photos[0]
            let originalSize = photo["original_size"] as! [String: Any]
            let urlString = originalSize["url"] as! String
            let url = URL(string: urlString)
            let placeholderImage = UIImage(named: "placeholder")
            let filter = AspectScaledToFillSizeWithRoundedCornersFilter(
                size: cell.photoImageView.frame.size,
                radius: 20.0)
            cell.photoImageView.af_setImage(withURL: url!,placeholderImage: placeholderImage, filter: filter,imageTransition: .crossDissolve(0.2)
            )}
            return cell
        }
    
    //code to fetch photos
    func fetchPhotos(){
        let url = URL(string: "https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/posts/photo?api_key=Q6vHoaVm5L1u2ZAW1fqv3Jw48gFzYVg9P0vH0VHl3GVy6quoGV")!
        
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        session.configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        
        //create a task to get the data
        let task = session.dataTask(with: request){
            (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
                self.networkErrorAlert(title: "Network Error", message: "Please try again later.")
            } else if let data = data {
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                print(dataDictionary)
                // Get the dictionary from the response key
                let responseDictionary = dataDictionary["response"] as! [String: Any]
                // Store the returned array of dictionaries in our posts property
                self.posts = responseDictionary["posts"] as! [[String: Any]]
                self.tableView.reloadData()
                //self.refreshControl.endRefreshing()
            }
        }
         task.resume()
    }
    
    //code to display error message when network fails
    func networkErrorAlert(title:String, message:String){
        let networkErrorAlert = UIAlertController(title: "Network Error", message: "The internet connection appears to be offline. Please try again later.", preferredStyle: UIAlertControllerStyle.alert)
            networkErrorAlert.addAction(UIAlertAction(title: "Try again", style: UIAlertActionStyle.default, handler: { (action) in self.fetchPhotos()}))
        self.present(networkErrorAlert, animated: true, completion: nil)
    }
    
    //code to load more data
    func loadMoreData() {
        
        let url = URL(string: "https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/posts/photo?api_key=Q6vHoaVm5L1u2ZAW1fqv3Jw48gFzYVg9P0vH0VHl3GVy6quoGV")!
        // ... Create the NSURLRequest (myRequest) ...
        //NSURLSession.sharedSession().dataTaskWithURL(resourceUrl, completionHandler: {(data, response, requestError) -> Void in

        let myRequest = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        
        // Configure session so that completion handler is executed on main UI thread
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate:nil, delegateQueue:OperationQueue.main
        )
        let task : URLSessionDataTask = session.dataTask(with: myRequest, completionHandler: { (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
                self.networkErrorAlert(title: "Network Error", message: "Please try again later.")
            } else if let data = data {
                // Update flag
                self.isMoreDataLoading = false
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                print(dataDictionary)
                // Get the dictionary from the response key
                let responseDictionary = dataDictionary["response"] as! [String: Any]
                // Store the returned array of dictionaries in our posts property
                self.posts = responseDictionary["posts"] as! [[String: Any]]
                self.tableView.reloadData()
               // self.refreshControl.endRefreshing()
            }
        })
        task.resume()
    }
    

    //code to display more results when scrolling
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
                isMoreDataLoading = true
                // ... Code to load more results ...
                loadMoreData()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
