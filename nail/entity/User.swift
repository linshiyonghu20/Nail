//
//  User.swift
//  nail
//
//  Created by Zhaoyu Yan on 12/11/18.
//  Copyright © 2018 Zhaoyu Yan. All rights reserved.
//

import Foundation

struct User: Decodable{
    var _id:String
    let username:String
    var password:String
    var photo: Photo
   
}
