//
//  DonorTrackApp.swift
//  DonorTrack
//
//  Created by Hunter Dobbelmann on 1/13/23.
//

//import ActivityKit
import SwiftUI

@main
struct DonorTrackApp: App {
	@StateObject private var store = TipStore()
	@StateObject private var reviewsManager = ReviewRequestManager()
	@State private var showThanks = false

	init() {
		// Enables haptics on first run
		UserDefaults.standard.register(defaults: [
			UDKeys.hapticsEnabled: true
		])
	}

    var body: some Scene {
        WindowGroup {
            ContentView()
				.environmentObject(reviewsManager)
                .environment(\.managedObjectContext, DonationsProvider.shared.viewContext)
				.environmentObject(store)
				.alert("Thank You! 😀", isPresented: $showThanks) {
					Button("Done") {}
				} message: {
					Text("Thank you so much for the tip! Your support is greatly appreciated ☺️")
						.foregroundColor(.indigo)
				}
				.onChange(of: store.action) { action in
					if action == .successful {
						showThanks = true
						store.reset()
					}
				}
//				.onReceive(NotificationCenter.default.publisher(for: UIApplication.willTerminateNotification), perform: { output in
//					if #available(iOS 16.2, *) {
//						let finishedDonationStatus = NewDonationAttributes.NewDonationStatus(startTime: .now, cycleCount: 0)
//						let finalContent = ActivityContent(state: finishedDonationStatus, staleDate: nil)
//
//						Task {
//							for activity in Activity<NewDonationAttributes>.activities {
//								await activity.end(finalContent, dismissalPolicy: .immediate)
//							}
//						}
//					}
//				})
        }
    }
}
