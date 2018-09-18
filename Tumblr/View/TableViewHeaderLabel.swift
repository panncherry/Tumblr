//
//  TableViewHeaderLabel.swift
//  Tumblr
//
//  Created by Pann Cherry on 9/15/18.
//  Copyright © 2018 Pann Cherry. All rights reserved.
//

import UIKit

class TableViewHeaderLabel: UILabel {
    var topInset:       CGFloat = 0
    var rightInset:     CGFloat = 12
    var bottomInset:    CGFloat = 0
    var leftInset:      CGFloat = 12
    
    override func drawText(in rect: CGRect) {
        
        let insets: UIEdgeInsets = UIEdgeInsets(top: self.topInset, left: self.leftInset, bottom: self.bottomInset, right: self.rightInset)
        self.setNeedsLayout()
        
        self.textColor = UIColor.black
        self.backgroundColor = UIColor.black
        
        self.lineBreakMode = .byWordWrapping
        self.numberOfLines = 0
        
        return super.drawText(in: rect.inset(by: insets))
    }

}
