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
    
    var counter: CounterAction? {
        get {
          guard case let .counter(value) = self else { return nil }
          return value
        }
        set {
          guard case .counter = self, let newValue = newValue else { return }
          self = .counter(newValue)
        }
      }

      var primeModal: PrimeModalAction? {
        get {
          guard case let .primeModal(value) = self else { return nil }
          return value
        }
        set {
          guard case .primeModal = self, let newValue = newValue else { return }
          self = .primeModal(newValue)
        }
      }

      var favoritePrimes: FavoritePrimesAction? {
        get {
          guard case let .favoritePrimes(value) = self else { return nil }
          return value
        }
        set {
          guard case .favoritePrimes = self, let newValue = newValue else { return }
          self = .favoritePrimes(newValue)
        }
      }
}


// state: inout AppState -> inout Int로 변경
func counterReducer(state: inout Int, action: CounterAction) {
    switch action {
    case .decrTapped:
        state -= 1
        
    case .incrTapped:
        state += 1
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

struct FavoritePrimesState {
    var favoritePrimes: [Int]
    var activityFeed: [AppState.Activity]
}

func favoritePrimesReducer(state: inout FavoritePrimesState, action: AppAction) {
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
    value: WritableKeyPath<GlobalValue, LocalValue>
//    get: @escaping (GlobalValue) -> LocalValue,
//    set: @escaping (inout GlobalValue, LocalValue) -> Void
) -> (inout GlobalValue, Action) -> Void {
    
    return { globalValue, action in
        reducer(&globalValue[keyPath: value], action)
//        var localValue = get(globalValue)
//        reducer(&localValue, action)
//        set(&globalValue, localValue)
    }
}

extension AppState {
    var favoritePrimesState: FavoritePrimesState {
        get {
            FavoritePrimesState(
                favoritePrimes: self.favoritePrimes,
                activityFeed: self.activityFeed
            )
        }
        set {
            self.favoritePrimes = newValue.favoritePrimes
            self.activityFeed = newValue.activityFeed
        }
    }
}

// 액션 pullback을 위한 keypath 재정의 ( enum)
struct _KeyPath<Root, Value> {
    let get: (Root) -> Value                // Root로 부터 Value 추출
    let set: (inout Root, Value) -> Void    // Value를 통해 Root 값 직접 설정 (inout 활용)
}

/// Enum의 연산자
///
/// 1) setter와 유사 (값 넣기)
/// AppAction.counter(CounterAction.incrTapped)
///
/// 2) getter와 유사 (값 추출)
/// let action = AppAction.favoritePrimes(.deleteFavoritePrimes([1]))
/// let favoritePrimes: FavoritePrimesAction?
/// switch action {
/// case let .favoritePrimes(action):
///     favoritePrimes = action
/// default:
///     favoritePrimes = nil
/// }


// Enum을 위한 KeyPath가 있다면 이런 형식일 것이다.
struct EnumKeyPath<Root, Value> {
    let embed: (Value) -> Root
    let extract: (Root) -> Value?
}

let _appReducer = combine(
//    pullback(counterReducer, value: \.count),
    primeModalReducer,
    pullback(favoritePrimesReducer, value: \.favoritePrimesState)
)

let appReducer = pullback(_appReducer, value: \.self)

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
