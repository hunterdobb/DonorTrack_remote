//
//  DataField.swift
//  DonorTrack
//
//  Created by Hunter Dobbelmann on 1/20/23.
//

import SwiftUI

struct DataField: View {
    @Binding var text: String
    let label: String
    let placeholder: String
    let color: Color
    var prefix: String? = nil
    var suffix: String? = nil

    var body: some View {
        LabeledContent {
            HStack(spacing: 0) {
                if let prefix {
                    Text(prefix)
                        .foregroundColor(color.opacity(text.isEmpty ? 0.5 : 1))                }

                TextField(text: $text) {
                    Text(placeholder)
                        .foregroundColor(color.opacity(0.5))
                }
                .fixedSize()
                .multilineTextAlignment(.trailing)
                .onChange(of: text, perform: { _ in
                    text = String(text.prefix(3))
                })

                if let suffix {
                    Text(" \(suffix)")
                        .foregroundColor(color.opacity(text.isEmpty ? 0.5 : 1))
                }
            }
            .foregroundColor(color)
            .font(.headline)
        } label: {
            Text(label)
        }
        .background(.clear).allowsHitTesting(true)
    }
}

struct DataField_Previews: PreviewProvider {
    static var previews: some View {
        DataField(text: .constant(""), label: "Protein", placeholder: "0.0", color: .orange, suffix: "g/dL")
            .padding()
            .previewDisplayName("Data Field w/ suffix")
            .previewLayout(.sizeThatFits)

        DataField(text: .constant(""), label: "Compensation", placeholder: "0", color: .green, prefix: "$")
            .padding()
            .previewDisplayName("Data Field w/ prefix")
            .previewLayout(.sizeThatFits)
    }
}
