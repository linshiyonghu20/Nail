//
//  Photo.swift
//  nail
//
//  Created by Zhaoyu Yan on 12/14/18.
//  Copyright © 2018 Zhaoyu Yan. All rights reserved.
//

import Foundation

struct Photo: Decodable {
    var type: String
    var data: [UInt8]
}
