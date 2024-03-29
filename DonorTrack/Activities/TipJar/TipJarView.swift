//
//  TipJarView.swift
//  DonorTrack
//
//  Created by Hunter Dobbelmann on 2/7/23.
//

import SwiftUI

struct TipJarView: View {
	@EnvironmentObject private var store: TipStore
//	@State private var showThanks = false

	var body: some View {
		VStack {
			icon
			description
			List {
				ForEach(store.items) { TipJarRow(item: $0) }
			}
			.alert(isPresented: $store.hasError, error: store.error) {}
		}
		.navigationBarTitleDisplayMode(.inline)
	}
}

struct TipJarView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
        	TipJarView()
				.navigationTitle("Tip Jar")
				.environmentObject(TipStore())
        }
    }
}

private extension TipJarView {
	var icon: some View {
		Image(systemName: "drop.fill")
			.frame(width: 100, height: 100)
			.font(.system(size: 60))
			.foregroundStyle(.yellow.gradient.opacity(0.7).shadow(.drop(radius: 5)))
			.background(.indigo.gradient, in: RoundedRectangle(cornerRadius: 20))
	}

	var description: some View {
		Text("I'm currently providing all features of Donor Track free of charge. If you'd like to support me and the future development of this app, any tips are greatly appreciated!")
			.padding(.vertical, 8)
			.padding(.horizontal, 32)
			.font(.system(.body, design: .rounded, weight: .medium))
	}
}
