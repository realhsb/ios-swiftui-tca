//
//  StandsList.swift
//  Standups_scrumdinger
//
//  Created by Soop on 4/24/25.
//

import ComposableArchitecture
import SwiftUI

struct StandupsListFeature: Reducer {
    struct State {
        @PresentationState var addStandup: StandupFormFeature.State?
        var standsups: IdentifiedArrayOf<Standup> = []
    }
    
    enum Action {
        case addButtonTapped
        case addStandup(PresentationAction<StandupFormFeature.Action>)
        case cancelStandupButtonTapped
        case saveStandupButtonTapped
    }
    
    // 외부 의존성을 명시적으로 정의, 주입. 테스트 가능성 증가
    @Dependency(\.uuid) var uuid
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
            case .addButtonTapped:
                // 비어있는 새 Standup을 만들고, 그 Standup을 관리하는 StandupFormFeature State 객체를 만든다
                state.addStandup = StandupFormFeature.State(standup: Standup(id: self.uuid()))
                return .none
                
            case .addStandup:
                return .none
                
            case .cancelStandupButtonTapped:
                state.addStandup = nil
                return .none
                
            case .saveStandupButtonTapped:
                guard let standup = state.addStandup?.standup
                else { return .none }
                state.standsups.append(standup)
                state.addStandup = nil
                return .none
            }
        }
        .ifLet(\.$addStandup, action: /Action.addStandup) { // 자식 reducer를 부모 reducer에 연결
            // \.$addStandup -> addStandup 값이 nil이 아니라면 자식 Reducer 활성화
            // action: /Action.addStandup -> 자식 Reducer에서 발생한 액션을 부모 Reducer에 연결
            StandupFormFeature()    // 자식 Reducer
        }
    }
}

struct StandsListView: View {
    
    let store: StoreOf<StandupsListFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: \.standsups) { viewStore in
            List {
                ForEach(viewStore.state) { standup in
                    CardView(standup: standup)
                        .listRowBackground(standup.theme.mainColor)
                }
            }
            .navigationTitle("Daily Standups")
            .toolbar {
                ToolbarItem {
                    Button("Add") {
                        viewStore.send(.addButtonTapped)
                    }
                }
            }
            // .sheet(store:content:) -> deprecated
            // WWDC 2023
            .sheet(
                store: self.store.scope(        // ⚠️ deprecated
                    state: \.$addStandup,       // 자식 상태 접근, @PresentationState인 상태의 바인딩을 가져오는 키패스
                    action: { .addStandup($0) } // 자식 액션을 부모 액션으로 감쌈, 자식에서 발생한 액션을 부모 Action enum의 .addStandup case로 감쌈
                )
//            ) { (store: StoreOf<StandupFormFeature>) in
            ) { store in
                NavigationStack {
                    StandupFormView(store: store)
                        .navigationTitle("New standup")
                        .toolbar {  // toolbar는 뷰 외부에서 설정. StandupFormView 재사용성 높임
                            ToolbarItem {
                                Button("Save") { viewStore.send(.saveStandupButtonTapped) }
                            }
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Cancel") { viewStore.send(.cancelStandupButtonTapped) }
                            }
                        }
                }
            }
        }
    }
}

struct CardView: View {
  let standup: Standup

  var body: some View {
    VStack(alignment: .leading) {
      Text(self.standup.title)
        .font(.headline)
      Spacer()
      HStack {
        Label(
          "\(self.standup.attendees.count)",
          systemImage: "person.3"
        )
        Spacer()
        Label(
          self.standup.duration.formatted(.units()),
          systemImage: "clock"
        )
        .labelStyle(.trailingIcon)
      }
      .font(.caption)
    }
    .padding()
    .foregroundColor(self.standup.theme.accentColor)
  }
}

struct TrailingIconLabelStyle: LabelStyle {
  func makeBody(
    configuration: Configuration
  ) -> some View {
    HStack {
      configuration.title
      configuration.icon
    }
  }
}

extension LabelStyle where Self == TrailingIconLabelStyle {
  static var trailingIcon: Self { Self() }
}

#Preview {
    MainActor.assumeIsolated {
        NavigationStack {
            StandsListView(
                store: Store(
                    initialState: StandupsListFeature.State(
                        standsups: [.mock]
                    )
                ) {
                    StandupsListFeature()
                        ._printChanges()
                }
            )
        }
    }
}
