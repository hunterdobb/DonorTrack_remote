//
//  SettingsView.swift
//  DonorTrack
//
//  Created by Hunter Dobbelmann on 2/4/23.
//

import SwiftUI

struct SettingsView: View {
	@AppStorage(UDKeys.hapticsEnabled) private var isHapticsEnabled = true

	var body: some View {
		NavigationStack {
			Form {
				hapticsToggle
			}
			.navigationTitle("Settings")
		}
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

private extension SettingsView {
	var hapticsToggle: some View {
		Toggle("Enable Haptics", isOn: $isHapticsEnabled)
	}
}
