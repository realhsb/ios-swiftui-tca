////
////  tca_basicTests.swift
////  tca-basicTests
////
////  Created by Subeen on 8/28/24.
////
//
//import ComposableArchitecture
//import XCTest
//@testable import tca_basic
//
//@MainActor
//final class tca_basicTests: XCTestCase {
//    func testCounter() async {
//        let store = TestStore(initialState: CounterFeature.State()) {
//            CounterFeature()
//        }
//        
//        await store.send(.incrementButtonTapped) {
//            $0.count = 1 // in-out state. action이 전송되기 전 state... 값을 맞춰주지 않으면 test failure
//            
//            /*
//               CounterFeature.State(
//             −   count: 0,
//             +   count: 1, ----> 실제 값은 1이므로, 1로 mutate
//                 fact: nil,
//                 isLoadingFact: false,
//                 isTimerOn: false
//               )
//             */
//        }
////        XCTAssertEqual(store.state.count, 1)
//    }
//    
//    func testTimer() async throws {
//        let clock = TestClock()
//        
//        let store = TestStore(initialState: CounterFeature.State()) {
//            CounterFeature()
//        } withDependencies: {
//            $0.continuousClock = clock
//        }
//        
//        await store.send(.toggleTimerButtonTapped) {
//            $0.isTimerOn = true
//        }
//        
//        await clock.advance(by: .seconds(1))
//        
//        await store.receive(.timerTicked) {
//            $0.count = 1
//        }
//        
//        await clock.advance(by: .seconds(1))
//        
//        await store.receive(.timerTicked) {
//            $0.count = 2
//        }
//        
//        await store.send(.toggleTimerButtonTapped) {
//            $0.isTimerOn = false
//        }
//    }
//    
//    func testGetFact() async {
//
//        let store = TestStore(initialState: CounterFeature.State()) {
//            CounterFeature()
//        } withDependencies: {
//            $0.continuousClock = ImmediateClock()
//        }
//        
//        await store.send(.getFactButtonTapped) {
//            $0.isLoadingFact = true
//        }
//        
//        await store.receive(.factResponse("???")) {
//            $0.isLoadingFact = false
//        }
//    }
//}
//
