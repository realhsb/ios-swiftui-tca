//
//  AppState.swift
//  tca-counter
//
//  Created by Subeen on 2/17/25.
//

import Foundation

class AppState: ObservableObject {
  @Published var count = 0
  @Published var favoritePrimes: [Int] = []
  @Published var loggedInUser: User?
  @Published var activityFeed: [Activity] = []

  struct Activity {
    let timestamp: Date
    let type: ActivityType

    enum ActivityType {
      case addedFavoritePrime(Int)
      case removedFavoritePrime(Int)
    }
  }

  struct User {
    let id: Int
    let name: String
    let bio: String
  }
}
