//
//  LoginResponse.swift
//  Tweets
//
//  Created by Sergio Carralero Nuño on 8/4/21.
//

import Foundation

struct LoginResponse: Codable {
    let user: User
    let token: String
}
