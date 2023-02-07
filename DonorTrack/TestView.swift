//
//  TestView.swift
//  DonorTrack
//
//  Created by Hunter Dobbelmann on 1/14/23.
//

import SwiftUI



struct TestView: View {
    @State private var donationDay: Date = Date()
        @State private var startTime: Date = Date()
        @State private var endTime: Date = Date()

        var body: some View {
            List {
                DatePicker("Date", selection: $donationDay, displayedComponents: .date)
                Text(donationDay, format: .dateTime).frame(maxWidth: .infinity, alignment: .leading)

                DatePicker("Start Time", selection: $startTime, displayedComponents: .hourAndMinute)
                Text(startTime, format: .dateTime).frame(maxWidth: .infinity, alignment: .leading)

                DatePicker("End Time", selection: $endTime, displayedComponents: .hourAndMinute)
                Text(endTime, format: .dateTime).frame(maxWidth: .infinity, alignment: .leading)
            }
            .onChange(of: donationDay) { value in
                var comps = Calendar.current.dateComponents([.year, .month, .day], from: value)
                comps.timeZone = TimeZone.current
                let calendar = Calendar.current

                let secondComps = calendar.dateComponents([.hour, .minute, .second], from: startTime)
                let thirdComps = calendar.dateComponents([.hour, .minute, .second], from: endTime)
                comps.hour = secondComps.hour
                comps.minute = secondComps.minute
                comps.second = secondComps.second
                self.startTime = calendar.date(from: comps)!
                comps.hour = thirdComps.hour
                comps.minute = thirdComps.minute
                comps.second = thirdComps.second
                self.endTime = calendar.date(from: comps)!
            }
            .onChange(of: endTime) { newValue in
                endTime = max(newValue, startTime)
            }
        }

}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
