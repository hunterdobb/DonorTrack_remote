//
//  WhiteGroupBoxStyle.swift
//  DonorTrack
//
//  Created by Hunter Dobbelmann on 4/4/23.
//

import SwiftUI

struct WhiteGroupBoxStyle: GroupBoxStyle {
	func makeBody(configuration: Configuration) -> some View {
		VStack(spacing: 0) {
			configuration.label
				.font(.headline)
				.frame(maxWidth: .infinity, alignment: .leading)

			configuration.content
		}
		.padding(8)
		.background(Color("ListRowColor"),
					in: RoundedRectangle(cornerRadius: 8, style: .continuous))
	}
}
