//
//  PhotoDetailsViewController.swift
//  Tumblr
//
//  Created by Pann Cherry on 9/13/18.
//  Copyright © 2018 Pann Cherry. All rights reserved.
//

import UIKit

class PhotoDetailsViewController: UIViewController {

    
    @IBOutlet weak var photoImageView: UIImageView!
    
    var post: [String: Any]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let post = post {
          if let photos = post["photos"] as? [[String: Any]]{
            //photoImageView = UIImageView(frame: frame)
            let photo = photos[0]
            let originalSize = photo["original_size"] as! [String: Any]
            let urlString = originalSize["url"] as! String
            let url = URL(string: urlString)
            let placeholderImage = UIImage(named: "placeholder")
           photoImageView.af_setImage(withURL: url!,placeholderImage: placeholderImage,imageTransition: .crossDissolve(0.2))
            
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
