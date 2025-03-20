//
//  AppState.swift
//  tca-counter
//
//  Created by Subeen on 2/17/25.
//

import Foundation

struct AppState {
    var count: Int = 0
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

enum PrimeModalAction {
    case saveFavoritePrimeTapped
    case removeFavoritePrimeTapped
}

enum FavoritePrimesAction {
    case deleteFavoritePrimes(IndexSet)
}

enum AppAction {
    case counter(CounterAction)
    case primeModal(PrimeModalAction)
    case favoritePrimes(FavoritePrimesAction)
}

// state: inout AppState -> inout Int로 변경
func counterReducer(state: inout Int, action: AppAction) {
    switch action {
    case .counter(.decrTapped):
        state -= 1
        
    case .counter(.incrTapped):
        state += 1
    
    default:
        break
    }
}

func primeModalReducer(state: inout AppState, action: AppAction) {
    switch action {
    case .primeModal(.saveFavoritePrimeTapped):
        state.favoritePrimes.removeAll(where: { $0 == state.count })
        state.activityFeed.append(.init(timestamp: Date(), type: .removedFavoritePrime(state.count)))
        
    case .primeModal(.removeFavoritePrimeTapped):
        state.favoritePrimes.append(state.count)
        state.activityFeed.append(.init(timestamp: Date(), type: .addedFavoritePrime(state.count)))
        
    default:
        break
    }
}

func favoritePrimesReducer(state: inout AppState, action: AppAction) {
    switch action {
        case let .favoritePrimes(.deleteFavoritePrimes(indexSet)):
            for index in indexSet {
                let prime = state.favoritePrimes[index]
                state.favoritePrimes.remove(at: index)
                state.activityFeed.append(
                    .init(
                        timestamp: Date(),
                        type: .removedFavoritePrime(prime)
                    )
                )
            }
        
        default:
            break
        
    }
}

// 큰 리듀서를 작은 리듀서로
func combine<Value, Action> (
    _ reducers: (inout Value, Action) -> Void...
//    _ first: @escaping (inout Value, Action) -> Void,
//    _ second: @escaping (inout Value, Action) -> Void
) -> (inout Value, Action) -> Void {
    
    return { value, action in
        for reducers in reducers {
            reducers(&value, action)
        }
//        first(&value, action)
//        second(&value, action)
    }
}

func pullback<LocalValue, GlobalValue, Action>(
    _ reducer: @escaping (inout LocalValue, Action) -> Void,
    get: @escaping (GlobalValue) -> LocalValue,
    set: @escaping (inout GlobalValue, LocalValue) -> Void
) -> (inout GlobalValue, Action) -> Void {
    
    return { globalValue, action in
        var localValue = get(globalValue)
        reducer(&localValue, action)
        set(&globalValue, localValue)
    }
}

let appReducer = combine(
    pullback(counterReducer, get: { $0.count }, set: { $0.count = $1 }),
    primeModalReducer,
    favoritePrimesReducer
)

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
