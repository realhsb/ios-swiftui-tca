//
//  AppView.swift
//  Standups_scrumdinger
//
//  Created by Soop on 5/13/25.
//

import ComposableArchitecture
import SwiftUI

struct AppFeature: Reducer {
  struct State {
      var path = StackState<Path.State>()   // 내비게이션
      var standupsList = StandupsListFeature.State()    // 기본 화면
  }
    
  enum Action {
      case path(StackAction<Path.State, Path.Action>)
      case standupsList(StandupsListFeature.Action)
  }
    
    struct Path: Reducer {  // 화면 전환
        enum State {
            case detail(StandupDetailFeature.State)
        }
        
        enum Action {
            case detail(StandupDetailFeature.Action)
            
        }
        
        var body: some ReducerOf<Self> {
            Scope(state: /State.detail, action: /Action.detail) {
                StandupDetailFeature()
            }
        }
    }
    
  var body: some ReducerOf<Self> {
      Scope(state: \.standupsList, action: /Action.standupsList) {
          StandupsListFeature()
      }
    Reduce { state, action in
      switch action {
      case let .path(.element(id: id, action: .detail(.delegate(action)))):
          
          switch action { // 자식이 변경 사실을 알려주면, standupslist배열을 갱신해서 UI 최신화
          case let .standupUpdated(standup):
              state.standupsList.standups[id: standup.id] = standup
              return .none
          }
          
////           (1) 자식뷰 내부에서 saveStandupButtonTapped 버튼을 눌렀을 때 -> 즉시 반영
//      case let .path(.element(id: id, action: .detail(.saveStandupButtonTapped))):
//          guard case let .some(.detail(detailState)) = state.path[id: id]
//          else { return .none }
//          state.standupsList.standups[id: detailState.standup.id] = detailState.standup
//          return .none
//          
////           (2) 뷰가 pop(뒤로 가기)될 때 -> 애니메이션이 끝나야 반영
////           자식 화면의 수정 내용을 부모가 최신화하는 방법 중 하나인 pop시 동기화 방식
//      case let .path(.popFrom(id: id)): // 사용자가 뒤로가기 / 스와이프해서 뷰 pop, stack에서 pop된 id를 전달 받음
//          guard case let .some(.detail(detailState)) = state.path[id: id] // pop 되기 전 상태를 stack에서 찾아냄. 이 상태가 detail인 경우만 작업 진행
//          else { return .none }
//          state.standupsList.standups[id: detailState.standup.id] = detailState.standup // 상세화면에서 편집된 최신 데이터를 리스트에 반영. standup.id로 기존 아이템을 찾아 덮어씌움.
//          return .none
          
      case .path:
          return .none
        
      case .standupsList:
          return .none
      }
    }
    .forEach(\.path, action: /Action.path) {
        Path()
    }
  }
}

struct AppView: View {
    
    let store: StoreOf<AppFeature>
    
  var body: some View {
    NavigationStackStore(
        self.store.scope(state: \.path, action: { .path($0) })
    ) {
        StandupsListView(
            store: self.store.scope(
                state: \.standupsList,
                action: { .standupsList($0) }
            )
        )
    } destination: { state in
        switch state {
        case .detail:
            CaseLet(
                /AppFeature.Path.State.detail,
                 action: AppFeature.Path.Action.detail,
                 then: StandupDetailView.init(store: )
            )
        }
    }
  }
}

#Preview {
    AppView(
        store: Store(
            initialState: AppFeature.State(
                standupsList: StandupsListFeature.State(standups: [.mock])
            )
        ) {
            AppFeature()
        }
    )
}
