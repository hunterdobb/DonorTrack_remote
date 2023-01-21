//
//  Date+Ext.swift
//  DonorTrack
//
//  Created by Hunter Dobbelmann on 1/16/23.
//

import Foundation

extension Date {
    static var durationFormat: DateComponentsFormatter {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.hour, .minute, .second]
        return formatter
    }
}

extension ClosedRange<Date> {
    func asDurationString() -> String {
        Date.durationFormat.string(from: self.upperBound.timeIntervalSince(self.lowerBound)) ?? "Error"
    }
}
