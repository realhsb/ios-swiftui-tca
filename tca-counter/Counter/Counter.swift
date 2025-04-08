//
//  Counter.swift
//  Counter
//
//  Created by Soop on 4/8/25.
//

import Foundation


public enum CounterAction {
    case decrTapped
    case incrTapped
}

// state: inout AppState -> inout Int로 변경
public func counterReducer(state: inout Int, action: CounterAction) {
    switch action {
    case .decrTapped:
        state -= 1
        
    case .incrTapped:
        state += 1
    }
}
