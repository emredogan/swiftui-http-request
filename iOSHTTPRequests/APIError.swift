//
//  APIError.swift
//  iOSHTTPRequests
//
//  Created by Emre Dogan on 23/01/2023.
//

import Foundation

enum APIError: Error {
	case dataCorrupted
	case decodingError
	case networkError
	case serverError(String)
}
