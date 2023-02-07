//
//  CheckmarkView.swift
//  DonorTrack
//
//  Created by Hunter Dobbelmann on 2/3/23.
//

import SwiftUI

struct CheckmarkView: View {
    var body: some View {
		Symbols.checkmark
			.font(.system(.largeTitle, weight: .bold))
			.padding(50)
			.background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20))
    }
}

struct CheckmarkView_Previews: PreviewProvider {
    static var previews: some View {
        CheckmarkView()
			.previewLayout(.sizeThatFits)
			.padding()
			.background(.blue.gradient)
    }
}
