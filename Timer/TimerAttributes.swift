//
//  TimerAttributes.swift
//  Timer
//
//  Created by Noah Sellers on 7/31/26.
//
//  Shared between the recipe-nest app target and the Timer widget extension
//  target so both can construct/render the same Live Activity.

import ActivityKit
import Foundation

struct TimerAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var endDate: Date
    }

    var timerID: String
    var label: String
}
