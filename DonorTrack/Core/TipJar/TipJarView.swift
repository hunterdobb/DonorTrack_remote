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
				ForEach(store.items) { item in
					TipJarRow(item: item)
				}
			}
//			.alert("Thank You! 😀", isPresented: $showThanks) {
//				Button("Done") {}
//			} message: {
//				Text("Thank you so much for your support!")
//					.foregroundColor(.indigo)
//			}
			.alert(isPresented: $store.hasError, error: store.error) {}
		}
		.navigationBarTitleDisplayMode(.inline)
//		.onChange(of: store.action) { action in
//			if action == .successful {
//				showThanks = true
//				store.reset()
//			}
//		}
	}
}

struct TipJarView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
        	TipJarView()
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

//	@ViewBuilder
//	var tipButtons: some View {
//		TipJarRow(title: "🙂 Kind Tip", amount: "$0.99")
//		TipJarRow(title: "☺️ Great Tip", amount: "$1.99")
//		TipJarRow(title: "🤩 Amazing Tip", amount: "$3.99")
//		TipJarRow(title: "🤯 Outrageous Tip", amount: "$7.99")
//	}
}
