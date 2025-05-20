//
//  StandupDetailView.swift
//  Standups_scrumdinger
//
//  Created by Soop on 5/7/25.
//

import ComposableArchitecture
import SwiftUI

struct StandupDetailFeature: Reducer {
    struct State: Equatable {
        @PresentationState var destination: Destination.State?
        var standup: Standup
    }

    enum Action {
        case cancelEditStandupButtonTapped
        case delegate(Delegate)
        case deleteButtonTapped
        case deleteMeetings(atOffsets: IndexSet)
        case destination(PresentationAction<Destination.Action>)
        case editButtonTapped
        case saveStandupButtonTapped
        enum Alert {
            case confirmDeletion
        }
        enum Delegate { // 자식 -> 부모 정보 전달
            case deleteStandup(id: Standup.ID)
            case standupUpdated(Standup)
        }
    }
    
    // SwiftUI의 `@Environment(\.dismiss) var dismiss`와 다른 점?
    // @Environment(\.dismiss)는 뷰 안에서 사용 가능. -> 로직이 많을 경우, 뷰에 복잡한 비즈니스 로직 섞임.
    // 반면, `@Dependency(\.dismiss)`는 Reducer내에서 사용 가능
    @Dependency(\.dismiss) var dismiss
    
    
    
    // 하나의 Enum으로 화면 전환 상태 관리하기
    struct Destination: Reducer {
        enum State: Equatable {
            case alert(AlertState<Action.Alert>)
            case editStandup(StandupFormFeature.State)
        }
        
        enum Action: Equatable {
            case alert(Alert)
            case editStandup(StandupFormFeature.Action)
            enum Alert {
                case confirmDeletion
            }
        }
        
        var body: some ReducerOf<Self> {
            Scope(
                state: /State.editStandup,
                action: /Action.editStandup
            ) {
                StandupFormFeature()
            }
        }
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .cancelEditStandupButtonTapped:
                state.destination = nil
                return .none
                
            case .delegate:
                return .none
                
            case .deleteButtonTapped:
                state.destination = .alert(
                    AlertState {
                        TextState("Are you sure you want to delete?")
                    } actions: {
                        ButtonState(role: .destructive, action: .confirmDeletion) {
                            TextState("Delete")
                        }
                    }
                )
                return .none
                
            case .deleteMeetings(atOffsets: let indices):
                state.standup.meetings.remove(atOffsets: indices)
                return .send(.delegate(.standupUpdated(state.standup)))
                
            // 화면 전환
            case .destination(.presented(.alert(.confirmDeletion))): // standups 편집창에서 delete 버튼을 눌렀을 때,
                return .run { [id = state.standup.id] send in
                    await send(.delegate(.deleteStandup(id: id)))
                    await self.dismiss()    // standsup 삭제시, 화면 pop-off
                }
              
            // 화면 전환
            case .destination:
                return .none
                
            case .editButtonTapped:
                state.destination = .editStandup(StandupFormFeature.State(standup: state.standup))
                return .none
                
            case .saveStandupButtonTapped:
                guard case let .editStandup(standupForm) = state.destination
                else { return .none }
                state.standup = standupForm.standup
                state.destination = nil
                return .send(
                    .delegate(.standupUpdated(standupForm.standup))
                )
            }
        }
        .ifLet(\.$destination, action: /Action.destination) {
            Destination()
        }
        .onChange(of: \.standup) { oldValue, newValue in
            /// 상태 변화 감지하여 자동 delegate 전송
            ///  일일이 .send(.delegate(...))를 붙이지 않아도 자동으로 처리 가능
            Reduce { state, action in
                .send(.delegate(.standupUpdated(newValue)))
            }
        }
    }
}


struct StandupDetailView: View {
    
    let store: StoreOf<StandupDetailFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in // observe: { $0 } -> Standup 전부 관찰
            List {
                Section {
                    NavigationLink {
                        
                    } label: {
                        Label("Start Meeting", systemImage: "timer")
                            .font(.headline)
                            .foregroundColor(.accentColor)
                    }
                    HStack {
                        Label("Length", systemImage: "clock")
                        Spacer()
                        Text(viewStore.standup.duration.formatted(.units()))
                    }
                    
                    HStack {
                        Label("Theme", systemImage: "paintpalette")
                        Spacer()
                        Text(viewStore.standup.theme.name)
                            .padding(4)
                            .foregroundColor(viewStore.standup.theme.accentColor)
                            .background(viewStore.standup.theme.mainColor)
                            .cornerRadius(4)
                    }
                } header: {
                    Text("Standup Info")
                }
                
                if !viewStore.standup.meetings.isEmpty {
                    Section {
                        ForEach(viewStore.standup.meetings) { meeting in
                            NavigationLink {
                                
                            } label: {
                                HStack {
                                    Image(systemName: "calendar")
                                    Text(meeting.date, style: .date)
                                    Text(meeting.date, style: .time)
                                }
                            }
                        }
                        .onDelete { indices in
                            viewStore.send(.deleteMeetings(atOffsets: indices))
                        }
                    } header: {
                        Text("Past meetings")
                    }
                }
                
                Section {
                    ForEach(viewStore.standup.attendees) { attendee in
                        Label(attendee.name, systemImage: "person")
                    }
                } header: {
                    Text("Attendees")
                }
                
                Section {
                    Button("Delete") {
                        viewStore.send(.deleteButtonTapped)
                    }
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle(viewStore.standup.title)
            .toolbar {
                Button("Edit") {
                    viewStore.send(.editButtonTapped)
                }
            }
            .alert(
                store: self.store.scope(state: \.$destination, action: { .destination($0) }),
                state: /StandupDetailFeature.Destination.State.alert,
                action: StandupDetailFeature.Destination.Action.alert
            )
            .sheet(store: self.store.scope(state: \.$destination, action: { .destination($0) }),
                   state: /StandupDetailFeature.Destination.State.editStandup,
                   action: StandupDetailFeature.Destination.Action.editStandup
            ) { store in
                NavigationStack {
                    StandupFormView(store: store)
                        .toolbar {
                            ToolbarItem {
                                Button("Save") {
                                    viewStore.send(.saveStandupButtonTapped)
                                }
                            }
                            
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Cancel") {
                                    viewStore.send(.cancelEditStandupButtonTapped)
                                }
                            }
                        }
                }
            }
            
        }
    }
}

#Preview {
  MainActor.assumeIsolated {
    NavigationStack {
        StandupDetailView(
            store: Store(initialState:
                            StandupDetailFeature.State(standup: .mock)) {
                                StandupDetailFeature()
                                    ._printChanges()
            }
        )
    }
  }
}
