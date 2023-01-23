//
//  HTTPExample.swift
//  iOSHTTPRequests
//
//  Created by Emre Dogan on 22/01/2023.
//

import Foundation

// Create a response struct
struct Response: Codable {
	let body: String
	let id: Int
	let title: String
	let userId: Int
}

class HTTPExample {
	private enum Constants: String, CaseIterable {
		case serviceToken = "X-ServiceToken"
		case appIdentifier = "native-app"

		static func isValidHeader(_ header: String) -> Bool {
			return allCases.map(\.rawValue).contains(header)
		}
	}

	private static let authenticationHeaders = [Constants.serviceToken.rawValue: "YourServiceToken"]
	
	init() {
		makePostRequest()
		
	}

	// In this particular example the model we post and the model we got in response is the same
	static func samplePostRequest() async -> Result<Response, APIError> {
		let model = Response(body: "The quick brown wolf jumped", id: 100, title: "Hello from Emre", userId: 1)
		let result = await post(model, expecting: Response.self, at: SampleURL.Auth.example)
		return result
	}
	
	// BASIC REQUEST
	func makePostRequest() {
		guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts") else {
			return
		}
		
		var request = URLRequest(url: url)
		
		// Method
		request.httpMethod = "POST"
		
		// Set header
		request.setValue("application/json", forHTTPHeaderField: "Content-Type") // header
		let body: [String: AnyHashable] = [
			"userId": 1,
			"title": "Hello from Emre",
			"body": "The quick brown wolf jumped"
		]
		
		// Set body
		request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .fragmentsAllowed)
		
		// Make the request
		let task = URLSession.shared.dataTask(with: request) { data, _, error in
			guard let data = data, error == nil else {
				return
			}
			
			do {
				let response = try JSONDecoder().decode(Response.self, from: data)
				print("Success \(response)")
			}
			catch {
				print(error)
			}
		}
		
		task.resume()
	}
	
	// HANDLE THE REQUEST WITH MORE GENERIC METHODS
	
	
	// Default http method is get
	private static func request(httpMethod: HTTPMethod = .get, httpBody: Data? = nil, parameters: [String: String] = [:], at endpoint: Endpoint) -> URLRequest {
		// First, we want to set the given parameters to the url.
		// This allows us to break down a URL into its components such as scheme, host, path, query.
		var components = URLComponents(url: endpoint.url, resolvingAgainstBaseURL: true)
		
		// Parameters are a set of key-value pairs that provide additional information about the resource being requested or the action being performed. They are added to the end of the URL after a (?) and are separated by (&).
		
		// For example, in the URL "https://www.example.com/search?query=example&sort=recent", the "query" and "sort" are the parameters, and "example" and "recent" are their respective values.
		
		// These parameters are often used to provide additional information to the server, such as specifying a specific search query or filtering results in a certain way.
		// So here we check if there are so parameters and add them to queryItem
		// queryItems are used to specify the parameters for a url,
		if parameters.count > 0 { components?.queryItems = parameters.map { URLQueryItem(name: $0.0, value: $0.1) } }

		// Create the request
		var request = URLRequest(url: components?.url ?? endpoint.url)
		// Set the given httpMethod
		request.httpMethod = httpMethod.rawValue
		// http body is nil by default but for example when you want post some data this is relevant. You might want to put the encoded object here: try? JSONEncoder().encode(object)
		request.httpBody = httpBody
		
		// Set header - standard thing.
		request.setValue("application/json", forHTTPHeaderField: "Content-Type" )

		// We need to set the authentication header to get access to the page.
		authenticationHeaders.forEach({ key, value in
			request.setValue(value, forHTTPHeaderField: key)
		})

		return request
	}

	private static func get<T: Codable>(expecting response: T.Type, parameters: [String: String] = [:], at endpoint: Endpoint) async -> Result<T, APIError> {
		// We follow the following two steps:
		// First we create the URL request, it is a get request with some parameters and endpoint (url address)
		let request = request(httpMethod: .get, parameters: parameters, at: endpoint)
		// We execute the request and give the response type that we expect to get
		return await execute(request: request, response: T.self)
	}

	// Here is there is two generic struct. In this one T is the type of what we are posting to the server and U is what we expect to get back
	private static func post<T: Codable, U: Codable>(_ object: T, expecting response: U.Type, parameters: [String: String] = [:], at endpoint: Endpoint) async -> Result<U, APIError> {
		let request = request(httpMethod: .post, httpBody: try? JSONEncoder().encode(object), parameters: parameters, at: endpoint)
		return await execute(request: request, response: U.self)
	}

	// Similar method with delete
	private static func delete<T: Codable>(expecting response: T.Type, parameters: [String: String] = [:], at endpoint: Endpoint) async -> Result<T, APIError> {
		let request = request(httpMethod: .delete, parameters: parameters, at: endpoint)
		return await execute(request: request, response: T.self)
	}
	
	// Example for POST
	// @discardableResult is the Swift attribute use to suppress the "Result unused" warning.
	@discardableResult
	static func signIn(email: String, password: String) async -> Result<SignInResponseModel, APIError> {
		// We create a model which we will post to the server.
		let model = SignInRequestModel(email: email, password: password, app: Constants.appIdentifier.rawValue)
		// We indicate that we are waiting for a sign-in response model
		return await post(model, expecting: SignInResponseModel.self, at: SampleURL.Auth.signIn)
	}
	
	// Result type: In success T generic, in fail API Error
	private static func execute<T: Codable>(request: URLRequest, response: T.Type) async -> Result<T, APIError> {
		do {
			// Downloads the contents of a URL based on the specified URL request and delivers the data asynchronously. It will return a data and response
			let (data, response) = try await URLSession.shared.data(for: request)
			
			// Check if the response object can be cast as an HTTPURLResponse otherwise it is a network error
			guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
				return .failure(.networkError)
			}

			// Print the status code and url string that we are querying
			debugPrint("[\(statusCode)] \(request.url?.absoluteString ?? "-")")

			let decoder = JSONDecoder()

			do {
				// Successful status codes
				if 200...399 ~= statusCode {
					// In case of success, decode the data based on response type T in the paraemeter
					let decodedData = try decoder.decode(T.self, from: data)
					// Return a success result type with the decoded data
					return .success(decodedData)
				} else {
					// Fail status codes
					// Return a failure state with appropriate API error
					return .failure(.serverError(String(statusCode)))
				}
			} catch {
				// If you can't decode return a failure with decoding error
				let errorDescription = "File: \(#file), Type: \(T.self): failed to decode api call: \(error)"
				debugPrint(errorDescription)
				return .failure(.decodingError)
			}
		} catch {
			// Check the type of the error and return relevant API error based on that
			return error.isNetworkError ? .failure(.networkError) : .failure(.serverError(error.localizedDescription))
		}
	}
	
	
	
}

protocol Endpoint {
	var url: URL { get }
}

enum HTTPMethod: String {
	case get = "GET"
	case post = "POST"
	case delete = "DELETE"
}

