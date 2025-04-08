//
//  FavoritePrimes.swift
//  tca-counter
//
//  Created by Soop on 4/8/25.
//

import Foundation

public enum FavoritePrimesAction {
    case deleteFavoritePrimes(IndexSet)
}

public func favoritePrimesReducer(state: inout [Int], action: FavoritePrimesAction) {
    switch action {
        case let .deleteFavoritePrimes(indexSet):
            for index in indexSet {
                state.remove(at: index)
        }
    }
}
