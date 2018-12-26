//
//  Comment.swift
//  nail
//
//  Created by Zhaoyu Yan on 12/13/18.
//  Copyright © 2018 Zhaoyu Yan. All rights reserved.
//

import Foundation

struct Comment: Decodable{
    var _id:String
    var username:String
    var userPhoto:Photo
    var placeId:String
    var placeName:String
    var placeAddress:String
    var content:String
    var publishDate:String
    var likes: Int
}
