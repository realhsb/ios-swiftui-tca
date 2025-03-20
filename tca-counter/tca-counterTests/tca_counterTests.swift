//
//  tca_counterTests.swift
//  tca-counterTests
//
//  Created by Soop on 3/13/25.
//

import XCTest
@testable import tca_counter
import SwiftUI

extension Binding {
    init(initialValue: Value) {
        var value = initialValue
        self.init(get: { value }, set: { value = $0 })
    }
}

class tca_counterTests: XCTestCase {
   
    func testIsPrimeModelView() {
        
//        let activityFeed = Binding<[AppState.Activity]>(initialValue: [])
//        
        let view = IsPrimeModalView(
            activityFeed: Binding<[AppState.Activity]>(initialValue: []),
            count: 2,
            favoritePrimes: Binding<[Int]>(initialValue: [2, 3, 5])
        )
        
//        let view = IsPrimeModalView(state: AppState())
        
        view.removeFavoritePrime()
        
        XCTAssertEqual(view.favoritePrimes, [3, 5])
        
        view.saveFavoritePrime()
        
        XCTAssertEqual(view.favoritePrimes, [3, 5, 2])
    }
    
    func testCounterView() {
        let view = CounterView(state: AppState())
        
        view.incrementCount()
        
//        let expected = AppState()
//        expected.count = 1
        XCTAssertEqual(view.state.count, 1)
        
        view.incrementCount()
        
        XCTAssertEqual(view.state.count, 2)
        
        view.decrementCount()
        
        XCTAssertEqual(view.state.count, 1)
        
        XCTAssertEqual(view.isNthPrimeButtonDisabled, false)
        
        view.nthPrimeButtonAction()
        
//        XCTAssertEqual(view.isNthPrimeButtonDisabled, true)
    }
}
