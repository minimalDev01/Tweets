//
//  PostRequest.swift
//  Tweets
//
//  Created by Sergio Carralero Nuño on 8/4/21.
//

import Foundation

struct PostRequest: Codable {
    let text: String
    let imageUrl: String?
    let videUrl: String?
    let location: PostRequestLocation?
}
