//
//  Cat.swift
//  Katze
//
//  Created by Mohamed Salama on 3/2/20.
//  Copyright © 2020 Mohamed Salama. All rights reserved.
//

import Foundation

struct Cat: Codable, Equatable {
    let id: String
    let imageURL: String
    let width: Int
    let height: Int
    
    private enum CodingKeys: String, CodingKey {
        case id
        case imageURL = "url"
        case width
        case height
    }
}

struct ErrorResponse: Codable {
    let message: String
    let status: Int
    let level: String
}
