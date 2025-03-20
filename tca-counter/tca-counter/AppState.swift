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

func counterReducer(state: AppState, action: CounterAction) -> AppState {
    var copy = state
    switch action {
    case .decrTapped:
        copy.count -= 1
//        return AppState(count: state.count - 1, favoritePrimes: state.favoritePrimes, loggedInUser: state.loggedInUser, activityFeed: state.activityFeed)
        
    case .incrTapped:
//        return AppState(count: state.count + 1, favoritePrimes: state.favoritePrimes, loggedInUser: state.loggedInUser, activityFeed: state.activityFeed)
        copy.count += 1
    }
    return copy
}

final class Store<Value, Action>: ObservableObject {
    let reducer: (Value, Action) -> Value
    @Published var value : Value
    
    init(initialValue: Value, reducer: @escaping (Value, Action) -> Value) {
        self.reducer = reducer
        self.value = initialValue
    }
    
    func send(_ action: Action) {
        self.value = self.reducer(self.value, action)
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
