//
//  Error+Extension.swift
//  iOSHTTPRequests
//
//  Created by Emre Dogan on 23/01/2023.
//

import Foundation

extension Error {

	var isNetworkError: Bool {
		let connectionErrorTypes = [
			URLError.Code.notConnectedToInternet.rawValue,
			URLError.Code.networkConnectionLost.rawValue,
			URLError.Code.cannotConnectToHost.rawValue
		]
		return connectionErrorTypes.contains((self as NSError).code)
	}
}
