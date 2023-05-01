//
//  BorderedTextFieldStyle.swift
//  DonorTrack
//
//  Created by Hunter Dobbelmann on 1/23/23.
//

import SwiftUI

// MARK: NOT USED

//struct DTFormTextFieldStyle: TextFieldStyle {
//    let color: Color
//    let title: String
//
//    func _body(configuration: TextField<Self._Label>) -> some View {
//        VStack(alignment: .leading, spacing: 0) {
//            Text(title)
//                .font(.headline)
//
//            configuration
//                .font(.system(.largeTitle, design: .rounded, weight: .bold))
//        }
//        .padding(8)
//        .foregroundColor(color)
//        .background {
//            RoundedRectangle(cornerRadius: 10)
//                .foregroundColor(color.opacity(0.2))
//        }
//    }
//
//}
//
//struct DTFormTextFieldStyle_Previews: PreviewProvider {
//    static var previews: some View {
//        TextField(text: .constant("")) {
//            Text("0.0")
//                .foregroundColor(.orange.opacity(0.3))
//                .font(.system(.largeTitle, design: .rounded, weight: .bold))
//        }
//        .textFieldStyle(DTFormTextFieldStyle(color: .orange, title: "Protein"))
//        .previewLayout(.sizeThatFits)
//        .padding()
//
//    }
//}
