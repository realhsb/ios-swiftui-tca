//
//  ContentView.swift
//  tca-counter
//
//  Created by Subeen on 2/17/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            NavigationLink(destination: EmptyView()) {
                Text("Counter Demo")
            }
            
            NavigationLink(destination: EmptyView()) {
                Text("Favorite primes")
            }
        }
    }
}

#Preview {
    ContentView()
}
