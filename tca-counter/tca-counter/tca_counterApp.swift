//
//  tca_counterApp.swift
//  tca-counter
//
//  Created by Subeen on 2/17/25.
//

import SwiftUI

@main
struct tca_counterApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(store: Store(initialValue: AppState(), reducer: counterReducer(state:action:)))
        }
    }
}
