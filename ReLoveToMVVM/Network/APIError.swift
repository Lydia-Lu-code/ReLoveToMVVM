//
//  APIError.swift
//  ReLoveToMVVM
//
//  Created by Lydia Lu on 2024/12/5.
//

import Foundation

enum APIError: Error {
    case invalidURL
    case networkError(Error)
    case serverError(Int)
    case decodingError
    case noData
    case htmlParsingError
    case redirectRequired(String)
}


