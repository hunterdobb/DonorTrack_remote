//
//  DonorTrackApp.swift
//  DonorTrack
//
//  Created by Hunter Dobbelmann on 1/13/23.
//

import SwiftUI

@main
struct DonorTrackApp: App {
	@StateObject private var store = TipStore()
	@State private var showThanks = false

	init() {
		UserDefaults.standard.register(defaults: [
			UDKeys.hapticsEnabled: true
		])
	}

    var body: some Scene {
        WindowGroup {
            ContentView()
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
        }
    }
}
