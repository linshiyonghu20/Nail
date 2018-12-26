//
//  Extensions.swift
//  nail
//
//  Created by Zhaoyu Yan on 12/13/18.
//  Copyright © 2018 Zhaoyu Yan. All rights reserved.
//

import Foundation
import UIKit

extension Date{
    
    func toString() -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = dateFormatter.string(from: self)
        return dateString
    }
    
    func timeAgo() -> String{
        let secondsAgo = Int64(Date().timeIntervalSince(self))
        
        let min:Int64 = 60
        let hour:Int64 = 60 * min
        let day:Int64 = 24 * hour
        let week:Int64 = 7 * day
        let month:Int64 = 30 * day
        let year:Int64 = 365 * day
        
        if secondsAgo < min {
            return "less than 1 min"
        }else if secondsAgo < hour {
            return "\(secondsAgo/min)mins ago"
        }else if secondsAgo < day {
            return "\(secondsAgo/hour)hours ago"
        }else if secondsAgo < week {
            return "\(secondsAgo/day)days ago"
        }else if secondsAgo < month {
            return "\(secondsAgo/week)weeks age"
        }else if secondsAgo < year {
            return "\(secondsAgo/month)months ago"
        }else {
            return "\(secondsAgo/year)years ago"
        }
    }
    
}

extension String{
    
    func toDate() -> Date{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatter.date(from: self)
        return date ?? Date()
    }
    
}

extension UIImage{
    
    func resizeImage(targetSize: CGSize) -> UIImage {
        let size = self.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x:0, y:0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func maskRoundedImage(radius: CGFloat) -> UIImage {
        let imageView: UIImageView = UIImageView(image: self)
        let layer = imageView.layer
        layer.masksToBounds = true
        layer.cornerRadius = radius
        UIGraphicsBeginImageContext(imageView.bounds.size)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return roundedImage!
    }
}
