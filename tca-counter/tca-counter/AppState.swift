//
//  AppState.swift
//  tca-counter
//
//  Created by Subeen on 2/17/25.
//

import Foundation

struct AppState {
    var count = 0
    var favoritePrimes: [Int] = []
    var loggedInUser: User?
    var activityFeed: [Activity] = []

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

enum CounterAction {
    case decrTapped
    case incrTapped
}

func counterReducer(state: inout AppState, action: CounterAction) {
    switch action {
    case .decrTapped:
        state.count -= 1
    case .incrTapped:
        state.count += 1
    }
}

final class Store<Value, Action>: ObservableObject {
    let reducer: (inout Value, Action) -> Void
    @Published var value : Value
    
    init(initialValue: Value, reducer: @escaping (inout Value, Action) -> Void) {
        self.reducer = reducer
        self.value = initialValue
    }
    
    func send(_ action: Action) {
        self.reducer(&self.value, action)
    }
}

// Store<AppState>

// @ObservedObject var state: AppState
// -> @ObservedObject var store: Store<AppState>

// self.state
// -> self.store.value

struct PrimeAlert: Identifiable {
    let prime: Int
    var id: Int { self.prime }
}
