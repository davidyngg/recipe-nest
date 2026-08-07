//
//  TimerLiveActivity.swift
//  Timer
//
//  Created by Noah Sellers on 7/31/26.
//

import ActivityKit
import WidgetKit
import SwiftUI

private func countdownRange(to endDate: Date) -> ClosedRange<Date> {
    let now = Date()
    return now...max(endDate, now)
}

struct TimerLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TimerAttributes.self) { context in
            HStack {
                Image(systemName: "timer")
                    .foregroundStyle(.orange)
                VStack(alignment: .leading) {
                    Text(context.attributes.label)
                        .font(.headline)
                    Text(timerInterval: countdownRange(to: context.state.endDate), countsDown: true)
                        .font(.title2)
                        .monospacedDigit()
                }
                Spacer()
            }
            .padding()
            .activityBackgroundTint(Color.black.opacity(0.85))
            .activitySystemActionForegroundColor(Color.white)

        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Label(context.attributes.label, systemImage: "timer")
                        .font(.headline)
                        .lineLimit(1)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(timerInterval: countdownRange(to: context.state.endDate), countsDown: true)
                        .font(.title3)
                        .monospacedDigit()
                }
            } compactLeading: {
                Image(systemName: "timer")
            } compactTrailing: {
                Text(timerInterval: countdownRange(to: context.state.endDate), countsDown: true)
                    .monospacedDigit()
                    .frame(width: 42)
            } minimal: {
                Image(systemName: "timer")
            }
        }
    }
}

extension TimerAttributes {
    fileprivate static var preview: TimerAttributes {
        TimerAttributes(timerID: "preview", label: "Sourdough Pancakes")
    }
}

extension TimerAttributes.ContentState {
    fileprivate static var fiveMinutes: TimerAttributes.ContentState {
        TimerAttributes.ContentState(endDate: Date().addingTimeInterval(5 * 60))
    }
}

#Preview("Notification", as: .content, using: TimerAttributes.preview) {
    TimerLiveActivity()
} contentStates: {
    TimerAttributes.ContentState.fiveMinutes
}
