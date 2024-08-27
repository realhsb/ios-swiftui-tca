//
//  ContentView.swift
//  tca-basic
//
//  Created by Subeen on 8/25/24.
//

import SwiftUI
import ComposableArchitecture

struct CounterFeature: Reducer {
    struct State: Equatable {   // State는 무조건 Equatable 프로토콜 준수
        var count = 0
        var fact: String?
        var isTimerOn = false
    }
    
    enum Action {   // user's doing
        case decrementButtonTapped
        case getFactButtonTapped
        case imcrementButtonTapped
        case toggleTimerButtonTapped
    }
    
    // ReducerOf<Self>
    var body: some Reducer<State, Action> { // return Effect
        Reduce { state, action in
            // state : 현재 상태, in-out parameter
            // action : 시스템으로 전달
            switch action {
            case .decrementButtonTapped:
                state.count -= 1
                return .none
                
            case .getFactButtonTapped:
                // TODO: perform network request
                return .none
                
            case .imcrementButtonTapped:
                state.count += 1
                return .none
                
            case .toggleTimerButtonTapped:
                state.isTimerOn.toggle()
                // TODO: start a timer
                return .none
            }
        }
    }
}

struct ContentView: View {
//    let store: Store<CounterFeature.State, CounterFeature.Action>
    let store: StoreOf<CounterFeature>
    
    var body: some View {
        
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            Form {
                Section {
//                    Text(self.store.state.count)
                    Text("\(viewStore.count)")
                    Button("Decrement") {
                        viewStore.send(.decrementButtonTapped)
                    }
                    
                    Button("Increment") {
                        viewStore.send(.imcrementButtonTapped)
                    }
                }
                
                Section {
                    Button("Get fact") {
                        viewStore.send(.getFactButtonTapped)
                    }
                    if let fact = viewStore.fact {
                        Text("Some fact")
                    }
                }
                
                Section {
                    if viewStore.isTimerOn {
                        Button("Stop timer") {
                            viewStore.send(.toggleTimerButtonTapped)
                        }
                    } else {
                        Button("Start timer") {
                            viewStore.send(.toggleTimerButtonTapped)
                        }
                    }
                }
            }
        }
    }
}

//#Preview {
//    ContentView(store: <#StoreOf<CounterFeature>#>)
//}
