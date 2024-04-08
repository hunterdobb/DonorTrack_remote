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

	@StateObject var dataController = DataController()

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
				.environment(\.managedObjectContext, dataController.container.viewContext)
				.environmentObject(dataController)
				.environmentObject(store)
				// TODO: This alert should probably be moved
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
        }
    }
}
