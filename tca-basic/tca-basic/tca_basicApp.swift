//
//  tca_basicApp.swift
//  tca-basic
//
//  Created by Subeen on 8/25/24.
//

import SwiftUI
import ComposableArchitecture

@main
struct tca_basicApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(
                store: Store(initialState: CounterFeature.State()) {
                    CounterFeature()
                }
            )
        }
    }
}
