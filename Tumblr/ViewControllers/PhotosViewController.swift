//
//  PhotosViewController.swift
//  Tumblr
//
//  Created by Pann Cherry on 9/6/18.
//  Copyright © 2018 Pann Cherry. All rights reserved.
//

import UIKit
import AlamofireImage
import AFNetworking

class PhotosViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    var refreshControl: UIRefreshControl!
    var loadingMoreView:InfiniteScrollActivityView?
    var posts: [[String: Any]] = []
    var isMoreDataLoading = false
    var postsOffset = 10 //initial number of posts to get
    
    let CellIdentifier = "TableViewCell", HeaderViewIdentifier = "TableViewHeaderView"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(PhotosViewController.didPullToRefresh(_:)), for: UIControl.Event.valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 275
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: CellIdentifier)
        tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: HeaderViewIdentifier)
        // Set up Infinite Scroll loading indicator
        let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        tableView.addSubview(loadingMoreView!)
        
        var insets = tableView.contentInset
        insets.bottom += InfiniteScrollActivityView.defaultHeight
        tableView.contentInset = insets
        fetchPhotos()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    
    //code to get the photo and insert into cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        // code to change color of the cell user selected
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.darkGray
        cell.selectedBackgroundView = backgroundView
        //code to set the color of all cells
        cell.contentView.backgroundColor = UIColor.white
        let post = posts[indexPath.section]
        if let photos = post["photos"] as? [[String: Any]]{
            let photo = photos[0]
            let originalSize = photo["original_size"] as! [String: Any]
            let urlString = originalSize["url"] as! String
            let url = URL(string: urlString)
            //cell.photoImageView.af_setImage(withURL: url!)
            let placeholderImage = UIImage(named: "photo_feed-1")
            let filter = AspectScaledToFillSizeWithRoundedCornersFilter(
                size: cell.photoImageView.frame.size,
                radius: 40.0)
            cell.photoImageView.af_setImage(withURL: url!,placeholderImage: placeholderImage, filter: filter,imageTransition: .crossDissolve(0.2)
            )}
        return cell
    }
    
    //code to remove grey selection effect
    func tableView(_tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        //Get rid of the gray selection effect by deselecting the cell with animation
        tableView.deselectRow(at: indexPath, animated: true)
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
                self.refreshControl.endRefreshing()
            }
        }
        task.resume()
    }
    
    //code to display avatar and publish date in the cell header
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?{
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        headerView.backgroundColor = UIColor(white: 1, alpha: 0.9)
        
        let profileView = UIImageView(frame: CGRect(x: 10, y: 5, width: 25, height: 25))
        profileView.clipsToBounds = true
        profileView.layer.cornerRadius = 15;
        profileView.layer.borderColor = UIColor(white: 0.7, alpha: 0.8).cgColor
        profileView.layer.borderWidth = 1;
        
        // Set the avatar
        profileView.setImageWith(URL(string:"https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/avatar")!)
        headerView.addSubview(profileView)
        
        //set date
        let label = UILabel(frame: CGRect(x: 58, y: 10, width: 250, height: 20))
        label.clipsToBounds = true
        label.text = posts[section]["date"] as? String
        headerView.addSubview(label)
        
        return headerView
    }
    
    //code to set the height of the header section
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
    
    //code to fetch photos when pull to refresh
    @objc func didPullToRefresh(_ refreshControl: UIRefreshControl) {
        fetchPhotos()
    }
    
    //code to display error message when network fails
    func networkErrorAlert(title:String, message:String){
        let networkErrorAlert = UIAlertController(title: "Network Error", message: "The internet connection appears to be offline. Please try again later.", preferredStyle: UIAlertController.Style.alert)
        networkErrorAlert.addAction(UIAlertAction(title: "Try again", style: UIAlertAction.Style.default, handler: { (action) in self.fetchPhotos()}))
        self.present(networkErrorAlert, animated: true, completion: nil)
    }
    
    //code to load more data
    func loadMoreData() {
        
        let url = URL(string:"https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/posts/photo?offset=\(self.postsOffset)&api_key=Q6vHoaVm5L1u2ZAW1fqv3Jw48gFzYVg9P0vH0VHl3GVy6quoGV")
        //get more posts
        self.postsOffset += 1
        let myRequest = URLRequest(url: url!)
        // Configure session so that completion handler is executed on main UI thread
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate:nil, delegateQueue:OperationQueue.main)
        let task : URLSessionDataTask = session.dataTask(with: myRequest, completionHandler: { (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
                self.networkErrorAlert(title: "Network Error", message: "Please try again later.")
            } else if let data = data {
                // Update flag
                self.isMoreDataLoading = false
                // Stop the loading indicator
                self.loadingMoreView!.stopAnimating()
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                print(dataDictionary)
                // Get the dictionary from the response key
                let responseDictionary = dataDictionary["response"] as! [String: Any]
                // Store the returned array of dictionaries in our posts property
                self.posts = responseDictionary["posts"] as! [[String: Any]]
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
            }
        })
        task.resume()
    }
    
    
    //code to display more posts when scrolling
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
                isMoreDataLoading = true
                // Update position of loadingMoreView, and start loading indicator
                let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                // Code to load more results
                loadMoreData()
            }
        }
    }
    
    //code to customize navigation bar
    override func viewDidAppear(_ animated: Bool) {
        let nav = self.navigationController?.navigationBar
        nav?.barStyle = UIBarStyle.black
        nav?.tintColor = UIColor.yellow
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        imageView.contentMode = .scaleAspectFit
        let image = UIImage(named: "photo_feed-1")
        imageView.image = image
        navigationItem.titleView = imageView
        navigationItem.title = "Back"
    }
    
    
    //code to connect with detailViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //Get the cell that triggered the segue
        let cell = sender as! UITableViewCell
        //Get the indexPath of the selected photo
        if let indexPath = tableView.indexPath(for: cell){
            let post = posts[indexPath.section]
            //Get a reference to the PhotoDetailsViewController
            let photoDetailsViewController = segue.destination as! PhotoDetailsViewController
            photoDetailsViewController.post = post
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
