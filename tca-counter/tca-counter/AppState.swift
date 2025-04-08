import Foundation
import SwiftUI
import ComposableArchitecture
import FavoritePrimes
import Combine
import Counter
import PrimeModal

struct AppState {
    var count: Int = 0
    var favoritePrimes: [Int] = []
//    var primeModal: PrimeModalState
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

extension AppState {
    var primeModal: PrimeModalState {
        get {
            PrimeModalState(
                count: self.count,
                favoritePrimes: self.favoritePrimes
            )
        }
        set {
            self.count = newValue.count
            self.favoritePrimes = newValue.favoritePrimes
        }
    }
}

let appReducer: (inout AppState, AppAction) -> Void = combine(
    pullback(counterReducer, value: \.count, action: \.counter),
    pullback(primeModalReducer, value: \.primeModal, action: \.primeModal),
    pullback(
        favoritePrimesReducer,
        value: \.favoritePrimes,
        action: \.favoritePrimes
    )
)

//let appReducer = pullback(_appReducer, value: \.self, action: \.self)





struct PrimeAlert: Identifiable {
    let prime: Int
    var id: Int { self.prime }
}
