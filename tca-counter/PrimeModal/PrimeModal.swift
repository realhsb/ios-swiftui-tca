//
//  PrimeModal.swift
//  PrimeModal
//
//  Created by Soop on 4/8/25.
//

public typealias PrimeModalState = (count: Int, favoritePrimes: [Int])

//public struct PrimeModalState {
//    public var count: Int
//    public var favoritePrimes: [Int] = []
//    
//    public init(count: Int, favoritePrimes: [Int]) {
//        self.count = count
//        self.favoritePrimes = favoritePrimes
//    }
//}

public enum PrimeModalAction {
    case saveFavoritePrimeTapped
    case removeFavoritePrimeTapped
}

public func primeModalReducer(
    state: inout PrimeModalState, // AppState -> PrimeModalState 로 수정
    action: PrimeModalAction
) -> Void {
    switch action {
    case .removeFavoritePrimeTapped:
        state.favoritePrimes.removeAll(where: { $0 == state.count })

        
    case .saveFavoritePrimeTapped:
        state.favoritePrimes.append(state.count)

    }
}
