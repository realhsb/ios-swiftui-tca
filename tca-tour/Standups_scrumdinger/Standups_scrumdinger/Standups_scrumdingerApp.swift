//
//  Standups_scrumdingerApp.swift
//  Standups_scrumdinger
//
//  Created by Soop on 4/24/25.
//

import ComposableArchitecture
import SwiftUI

@main
struct Standups_scrumdingerApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                StandsListView(
                    store: Store(
                        initialState: StandupsListFeature.State()
                    ) {
                        StandupsListFeature()
                    }
                )
            }
        }
    }
}
