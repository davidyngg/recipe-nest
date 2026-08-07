//
//  RecipeTimer.swift
//
//
//  Created by Noah Sellers on 7/31/26.
//

import Foundation

struct RecipeTimer: Codable, Identifiable, Hashable {
    var id: UUID = UUID()
    var label: String
    var duration: TimeInterval
    var endDate: Date?
    var remaining: TimeInterval

    var isRunning: Bool {
        endDate != nil
    }

    var displayRemaining: TimeInterval {
        guard let endDate else { return remaining }
        return max(0, endDate.timeIntervalSinceNow)
    }

    mutating func start() {
        endDate = Date().addingTimeInterval(remaining)
    }

    mutating func pause() {
        remaining = displayRemaining
        endDate = nil
    }

    mutating func reset() {
        endDate = nil
        remaining = duration
    }
}

final class TimerStore {
    static let shared = TimerStore()

    private(set) var timers: [RecipeTimer] = []

    private let fileURL: URL = {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return dir.appendingPathComponent("timers.json")
    }()

    private init() {
        load()
        LiveActivityManager.shared.refresh(with: timers)
    }

    func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode([RecipeTimer].self, from: data) else {
            timers = []
            return
        }
        timers = decoded
    }

    func save() {
        guard let data = try? JSONEncoder().encode(timers) else { return }
        try? data.write(to: fileURL)
    }

    func add(_ timer: RecipeTimer) {
        timers.append(timer)
        save()
        LiveActivityManager.shared.refresh(with: timers)
    }

    func update(_ timer: RecipeTimer) {
        guard let index = timers.firstIndex(where: { $0.id == timer.id }) else { return }
        timers[index] = timer
        save()
        LiveActivityManager.shared.refresh(with: timers)
    }

    func delete(_ timer: RecipeTimer) {
        timers.removeAll { $0.id == timer.id }
        save()
        LiveActivityManager.shared.refresh(with: timers)
    }
}

extension TimeInterval {
    var timerDisplay: String {
        let total = Int(self.rounded())
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        let seconds = total % 60
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
