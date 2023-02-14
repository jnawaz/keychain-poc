//
//  ContentView.swift
//  Keychain
//
//  Created by Jamil Nawaz on 14/02/2023.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Link("Get certs", destination: URL(string: "http://localhost:80/iphone.p13")!)
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
