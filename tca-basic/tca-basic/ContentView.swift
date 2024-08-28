//
//  ContentView.swift
//  tca-basic
//
//  Created by Subeen on 8/25/24.
//

import SwiftUI
import ComposableArchitecture

struct NumberFactClient {
    var fetch: @Sendable (Int) async throws -> String
}

extension NumberFactClient: DependencyKey {
    static let liveValue = Self { number in
        let (data, _) = try await URLSession.shared.data(
            from: URL(string: "http://www.numbersapi.com/\(number)")!
        )
        return String(decoding: data, as: UTF8.self)
        
    }
}

extension DependencyValues {
    var numberFact: NumberFactClient {
        get { self[NumberFactClient.self] }
        set { self[NumberFactClient.self] = newValue}
    }
}

struct CounterFeature: Reducer {
    struct State: Equatable {   // State는 무조건 Equatable 프로토콜 준수
        var count = 0
        var fact: String?
        var isLoadingFact = false
        var isTimerOn = false
    }
    
    enum Action: Equatable {   // user's doing
        case decrementButtonTapped
        case factResponse(String)
        case getFactButtonTapped
        case incrementButtonTapped
        case timerTicked
        case toggleTimerButtonTapped
    }
    
    private enum CancelID {
        case timer
    }
    
    @Dependency(\.continuousClock) var clock
    @Dependency(\.numberFact) var numberFact
    
    // Reducer<State, Action>
    var body: some ReducerOf<Self> { // return Effect
        Reduce { state, action in
            // state : 현재 상태, in-out parameter
            // action : 시스템으로 전달
            switch action {
            case .decrementButtonTapped:
                state.count -= 1
                state.fact = nil
                return .none
                
            case let .factResponse(fact):   // 바뀐 값을 업데이트하는 action
                state.fact = fact
                state.isLoadingFact = false
                return .none
                
            case .getFactButtonTapped:
                state.fact = nil
                state.isLoadingFact = true
                /// Mutable capture of 'inout' parameter 'state' is not allowed in concurrently-executing code 에러 발생 -> [count = state.count ] 진행
                return .run { [count = state.count ] send in   // 비동기
                    try await send(.factResponse(self.numberFact.fetch(count)))
                    
                    // 바뀐 값을 어떻게 화면에 업데이트 하나? mutate 값을 ...? state.fact = fact 이렇게 하면 안 됨
                    // send 를 통해 값을 업데이트 하는 action을 정의한다.
                }
                
            case .incrementButtonTapped:
                state.fact = nil
                state.count += 1
                return .none
                
            case .timerTicked:
                state.count += 1
                return .none
                
            case .toggleTimerButtonTapped:
                state.isTimerOn.toggle()
                if state.isTimerOn {
                    // Start the timer
                    return .run { send in
                        for await _ in self.clock.timer(interval: .seconds(1)) {
                            await send(.timerTicked)
                        }
                    }
                    .cancellable(id: CancelID.timer) // 취소 effect 연결. 같은 id를 통해 해당 action을 cancel 할 수 있다.
                } else {
                    return .cancel(id: CancelID.timer)  // 연결한 action을 cancel
                }
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
                        viewStore.send(.incrementButtonTapped)
                    }
                }
                
                Section {
                    Button {
                        viewStore.send(.getFactButtonTapped)
                    } label: {
                        HStack {
                            Text("Get fact")
                            if viewStore.isLoadingFact {
                                Spacer()
                                ProgressView()
                            }
                        }
                    }
                    if let fact = viewStore.fact {
                        Text(fact)
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

#Preview {
    ContentView(
        store: Store(initialState: CounterFeature.State()) {
            CounterFeature()
                ._printChanges()    // print on console
        }
    )
}
