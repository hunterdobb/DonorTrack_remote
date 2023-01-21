//
//  TestView.swift
//  DonorTrack
//
//  Created by Hunter Dobbelmann on 1/14/23.
//

import SwiftUI



struct TestView: View {
    @State private var text: String = ""

    var body: some View {
        Button {
            HapticManager.instance.impact(style: .rigid)
        } label: {
            Image(systemName: "plus")
                .frame(width: 100, height: 35)
        }
        .buttonStyle(AnimatedCapsule(color: .orange))
    }

}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
