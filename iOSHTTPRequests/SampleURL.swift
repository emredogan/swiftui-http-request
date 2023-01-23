//
//  SampleURL.swift
//  iOSHTTPRequests
//
//  Created by Emre Dogan on 23/01/2023.
//

import Foundation

enum SampleURL {

	static var websiteURL: String {
		"https://websiteurlgoeshere.com)"
	}

	enum Auth: Endpoint {
		case signIn
		case example

		var url: URL {
			switch self {
				case .signIn:
					return URL(string: "\(websiteURL)/customer/account/authenticate")!
				case .example:
					return URL(string: "https://jsonplaceholder.typicode.com/posts")!
			}
		}
	}
}
