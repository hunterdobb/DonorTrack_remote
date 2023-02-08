//
//  TipJarRow.swift
//  DonorTrack
//
//  Created by Hunter Dobbelmann on 2/7/23.
//

import StoreKit
import SwiftUI

struct TipJarRow: View {
	@EnvironmentObject private var store: TipStore
	let item: Product?

    var body: some View {
		HStack {
			Button(item?.description ?? "🙂 Kind Tip") {
				if let item {
					Task {
						await store.purchase(item)
					}
				}
			}
			.foregroundColor(.indigo)
			.font(.headline)

			Spacer()
			Text("\(item?.displayPrice ?? "$0.99")")
		}
    }
}

struct TipJarRow_Previews: PreviewProvider {
    static var previews: some View {
		TipJarRow(item: nil)
			.environmentObject(TipStore())
			.padding()
			.previewLayout(.sizeThatFits)
    }
}
