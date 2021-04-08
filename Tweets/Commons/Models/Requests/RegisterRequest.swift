//
//  RegisterRequest.swift
//  Tweets
//
//  Created by Sergio Carralero Nuño on 8/4/21.
//

import Foundation

struct RegisterRequest: Codable {
    let email: String
    let password: String
    let names: String
}
