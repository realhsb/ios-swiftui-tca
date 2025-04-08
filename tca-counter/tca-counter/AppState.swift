import Foundation
import SwiftUI

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

func primeModalReducer(
    state: inout AppState,
    action: PrimeModalAction
) -> Void {
    switch action {
    case .removeFavoritePrimeTapped:
        state.favoritePrimes.removeAll(where: { $0 == state.count })

        
    case .saveFavoritePrimeTapped:
        state.favoritePrimes.append(state.count)

    }
}

func favoritePrimesReducer(state: inout [Int], action: FavoritePrimesAction) {
    switch action {
        case let .deleteFavoritePrimes(indexSet):
            for index in indexSet {
                state.remove(at: index)
        }
    }
}

func activityFeed(
    _ reducer: @escaping (inout AppState, AppAction) -> Void
) -> (inout AppState, AppAction) -> Void {
    return { state, action in
            switch action {
            case .counter:
                break
                
            case .primeModal(.removeFavoritePrimeTapped):
                state.activityFeed.append(
                    .init(
                        timestamp: Date(),
                        type: .removedFavoritePrime(state.count)
                    )
                )

            case .primeModal(.saveFavoritePrimeTapped):
                state.activityFeed.append(
                    .init(
                        timestamp: Date(),
                        type: .addedFavoritePrime(state.count)
                    )
                )
                
            case let .favoritePrimes(.deleteFavoritePrimes(indexSet)):
                for index in indexSet {
                    state.activityFeed.append(.init(timestamp: Date(), type: .removedFavoritePrime(state.favoritePrimes[index])))
            }
        }
        
        reducer(&state, action)
    }
}

// 큰 리듀서를 작은 리듀서로
func combine<Value, Action> (
    _ reducers: (inout Value, Action) -> Void...
) -> (inout Value, Action) -> Void {
    
    return { value, action in
        for reducers in reducers {
            reducers(&value, action)
        }
    }
}


func pullback<GlobalValue, LocalValue, GlobalAction, LocalAction>(
  _ reducer: @escaping (inout LocalValue, LocalAction) -> Void,
  value: WritableKeyPath<GlobalValue, LocalValue>,
  action: WritableKeyPath<GlobalAction, LocalAction?>
) -> (inout GlobalValue, GlobalAction) -> Void {

  return { globalValue, globalAction in
    guard let localAction = globalAction[keyPath: action]
    else { return }

    reducer(&globalValue[keyPath: value], localAction)
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

// 기존의 reducer를 받아서, 이를 변형하거나 확장
func higherOrderReducer(
    _ reducer: @escaping (inout AppState, AppAction) -> Void
) -> (inout AppState, AppAction) -> Void {
    return { state, action in
        // do some computations with state and action
        reducer(&state, action)
        
    }
}

let _appReducer: (inout AppState, AppAction) -> Void = combine(
    pullback(counterReducer, value: \.count, action: \.counter),
    pullback(primeModalReducer, value: \.self, action: \.primeModal),
    pullback(
        favoritePrimesReducer,
        value: \.favoritePrimes,
        action: \.favoritePrimes
    )
)

let appReducer = pullback(_appReducer, value: \.self, action: \.self)

func logging<Value, Action>(
    _ reducer: @escaping (inout Value, Action) -> Void
) -> (inout Value, Action) -> Void {
    return { value, action in
        reducer(&value, action)
        print("Action: \(action)")
        print("Value:")
        dump(value)
        print("---")
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

struct PrimeAlert: Identifiable {
    let prime: Int
    var id: Int { self.prime }
}
