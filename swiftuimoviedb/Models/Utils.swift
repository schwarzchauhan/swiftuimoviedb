//
//  Utils.swift
//  swiftuimoviedb
//
//  Created by Harsh Chauhan on 11/4/26.
//

import Foundation

class Utils {
    static let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        return decoder
    }()
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
