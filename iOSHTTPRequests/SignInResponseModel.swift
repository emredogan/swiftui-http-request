//
//  SignInResponseModel.swift
//  iOSHTTPRequests
//
//  Created by Emre Dogan on 23/01/2023.
//

import Foundation

struct SignInResponseModel: Codable {
	var body: SignInInfo
}

struct SignInInfo: Codable {
	var sessionToken: String
	var account: AccountInfo
}

struct AccountInfo: Codable {
	var accountId: Int
	var clientUserId: Int
	var email: String
	var name: String
	var entitlements: [String]
}
