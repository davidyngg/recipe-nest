//
//  LiveActivityManager.swift
//
//
//  Created by Noah Sellers on 7/31/26.
//

import ActivityKit
import Foundation

final class LiveActivityManager {
    static let shared = LiveActivityManager()

    private var currentActivity: Activity<TimerAttributes>?

    private init() {
        // Reattach to a Live Activity that's still running from a previous
        // launch, and clean up any extras left over from an earlier crash.
        let existingActivities = Activity<TimerAttributes>.activities
        currentActivity = existingActivities.first
        for stale in existingActivities.dropFirst() {
            Task { await stale.end(nil, dismissalPolicy: .immediate) }
        }
    }

    func refresh(with timers: [RecipeTimer]) {
        guard let closest = closestRunningTimer(in: timers), let endDate = closest.endDate else {
            endActivity()
            return
        }

        if let activity = currentActivity, activity.attributes.timerID == closest.id.uuidString {
            let content = ActivityContent(state: TimerAttributes.ContentState(endDate: endDate), staleDate: endDate)
            Task { await activity.update(content) }
        } else {
            endActivity()
            startActivity(label: closest.label, timerID: closest.id.uuidString, endDate: endDate)
        }
    }

    private func closestRunningTimer(in timers: [RecipeTimer]) -> RecipeTimer? {
        timers
            .filter { $0.isRunning }
            .min { ($0.endDate ?? .distantFuture) < ($1.endDate ?? .distantFuture) }
    }

    private func startActivity(label: String, timerID: String, endDate: Date) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        let attributes = TimerAttributes(timerID: timerID, label: label)
        let content = ActivityContent(state: TimerAttributes.ContentState(endDate: endDate), staleDate: endDate)

        do {
            currentActivity = try Activity.request(attributes: attributes, content: content)
        } catch {
            print("Failed to start Live Activity: \(error)")
        }
    }

    private func endActivity() {
        guard let activity = currentActivity else { return }
        currentActivity = nil
        Task { await activity.end(nil, dismissalPolicy: .immediate) }
    }
}
