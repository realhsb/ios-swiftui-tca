//
//  Standups_scrumdingerApp.swift
//  Standups_scrumdinger
//
//  Created by Soop on 4/24/25.
//

import ComposableArchitecture
import SwiftUI

@main
struct Standups_scrumdingerApp: App {
    var body: some Scene {
        WindowGroup {
            var editedStandup = Standup.mock
            let _ = editedStandup.title += "Morning Sync"
            
            // deep link 만들기
            // 값을 미리 입력해서 앱의 특정 화면에 진입시킴
            // 바닐라 스유는 상태를 구성해도 자동으로 특정 뷰로 이동시킬 수 없음.
            AppView(
                store: Store(
                    initialState: AppFeature.State(
                        path: StackState([
                            .detail(
                                StandupDetailFeature.State(
                                    editStandup: StandupFormFeature.State(
                                        focus: .attendee(editedStandup.attendees[3].id),
                                        standup: editedStandup
                                    ),
                                    standup: .mock
                                )
                            )
                        ])
                    )) {
                       AppFeature()
                            ._printChanges()
                    }
            )
        }
    }
}
