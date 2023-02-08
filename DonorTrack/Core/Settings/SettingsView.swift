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

	var body: some View {
		NavigationStack {
			Form {
				hapticsToggle

				Section {
					tipJar
				}

			}
			.navigationTitle("Settings")
			
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
}
