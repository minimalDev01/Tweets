//
//  Post.swift
//  Tweets
//
//  Created by Sergio Carralero Nuño on 8/4/21.
//

import Foundation

struct Post: Codable {
    let id: String
    let author: User
    let imageUrl: String
    let videoUrl: String
    let text: String
    let location: PostLocation
    let hasVideo: Bool
    let hasImage: Bool
    let hasLocation: Bool
    let createdAt: String
}
