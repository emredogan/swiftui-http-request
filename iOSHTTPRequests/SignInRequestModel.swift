//
//  SignInRequestModel.swift
//  iOSHTTPRequests
//
//  Created by Emre Dogan on 23/01/2023.
//

import Foundation

struct SignInRequestModel: Codable {
	var email: String
	var password: String
	var app: String
}
