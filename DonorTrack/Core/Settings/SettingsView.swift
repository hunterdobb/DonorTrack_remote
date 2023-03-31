//
//  SettingsView.swift
//  DonorTrack
//
//  Created by Hunter Dobbelmann on 2/4/23.
//

import SwiftUI

struct SettingsView: View {
	@AppStorage(UDKeys.hapticsEnabled) private var isHapticsEnabled = true

	@EnvironmentObject private var store: TipStore
	@EnvironmentObject private var reviewsManager: ReviewRequestManager

	@Environment(\.openURL) var openURL

	var body: some View {
		NavigationStack {
			Form {
				Section {
					hapticsToggle
				} footer: {
					Text("Haptics are the small vibrations you feel when tapping on certain buttons.")
				}
				Section {
					tipJar
					rate
				} footer: {
					VStack(alignment: .leading) {
						Text("If you're enjoying Donor Track, please consider rating the app on the App Store.")
						currentVersion
					}
				}
			}
			.navigationTitle("Settings")
			
		}
    }

	func getCurrentVersion() -> String {
		// Get the current bundle version for the app. (Similar to Apple sample app)
		if let currentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
			return "Current Version: \(currentVersion)"
		} else {
			return "error"
		}
	}
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
			.environmentObject(TipStore())
    }
}

private extension SettingsView {
	var hapticsToggle: some View {
		Toggle("Enable Haptics", isOn: $isHapticsEnabled)
	}

	var tipJar: some View {
		NavigationLink {
			TipJarView()
				.environmentObject(store)
		} label: {
			HStack {
				Image(systemName: "bag.fill")
					.foregroundColor(.white)
					.padding(5)
					.background {
						RoundedRectangle(cornerRadius: 7)
							.foregroundStyle(.indigo)
							.aspectRatio(CGSize(width: 1, height: 1), contentMode: .fit)
					}

				Text("Tip Jar")
					.font(.system(.headline, design: .rounded))
			}
		}
	}

	var rate: some View {
		Button {
			if let url = reviewsManager.reviewLink {
				openURL(url)
			}
		} label: {
			HStack {
				Image(systemName: "heart.fill")
					.foregroundColor(.white)
					.padding(5)
					.background {
						RoundedRectangle(cornerRadius: 7)
							.foregroundStyle(.red)
							.aspectRatio(CGSize(width: 1, height: 1), contentMode: .fit)
					}

				Text("Rate Donor Track")
					.font(.system(.headline, design: .rounded))
					.foregroundColor(.primary)

				Spacer()

				Image(systemName: "arrow.up.right")
					.fontWeight(.medium)
					.imageScale(.small)
//					.foregroundStyle(.tertiary)
					.foregroundColor(.secondary.opacity(0.6))

			}
		}
	}

	var currentVersion: some View {
		Text(getCurrentVersion())
			.frame(maxWidth: .infinity, alignment: .center)
			.padding(.top)
	}
}
