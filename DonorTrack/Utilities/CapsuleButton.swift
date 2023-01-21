//
//  CapsuleButton.swift
//  DonorTrack
//
//  Created by Hunter Dobbelmann on 1/16/23.
//

import SwiftUI

/*
 Button {

 } label: {
     Image(systemName: "arrow.uturn.backward")
         .font(.largeTitle)
         .frame(width: 50, height: 35)
         .bold()
 }
//                        .disabled(cycleCount <= 1)
 .buttonStyle(.bordered)
 .buttonBorderShape(.capsule)
 .tint(.orange)

 Button {

 } label: {
     Image(systemName: "plus")
         .font(.largeTitle)
         .frame(width: 100, height: 35)
         .bold()
 }
 .buttonStyle(.bordered)
 .buttonBorderShape(.capsule)
 .tint(.blue)
 */

struct AnimatedCapsule: ButtonStyle {
    let color: Color
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(color)
            .font(.largeTitle)
            .bold()
            .padding(8)
            .background {
                Capsule()
                    .fill(color.opacity(0.2))
            }
            .opacity(configuration.isPressed ? 0.6 : 1)
            .scaleEffect(configuration.isPressed ? 0.9 : 1)
            .animation(.easeOut(duration: 0.09), value: configuration.isPressed)
    }

}

//extension ButtonStyle where Self == AnimatedButtonStyle {
//    static var animated: Self {
//        .init(color: .blue)
//    }
//}
