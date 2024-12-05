//
//  User.swift
//  ReLoveToMVVM
//
//  Created by Lydia Lu on 2024/11/26.
//

import Foundation

struct User: Codable {
    let id: String
    let username: String
    let email: String
    let phoneNumber: String?
    let avatarUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case email
        case phoneNumber = "phone_number"
        case avatarUrl = "avatar_url"
    }
}
