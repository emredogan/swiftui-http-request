//
//  ContentView.swift
//  iOSHTTPRequests
//
//  Created by Emre Dogan on 22/01/2023.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
        }
        .padding()
		.task {
			// This one using generic methods to make the same request
			let response = await HTTPExample.samplePostRequest()
			
			switch response {
				case .success(let result):
					print(result.title)
				case .failure(let error):
					print(error.localizedDescription)
			}
		}
		.onAppear {
			
			// This one uses the classic way of making post request in the initializer
			let example = HTTPExample()
		}
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
