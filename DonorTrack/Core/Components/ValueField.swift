//
//  ValueField.swift
//  DonorTrack
//
//  Created by Hunter Dobbelmann on 1/14/23.
//

import SwiftUI

struct ValueField: View {
    @Binding var text: String
    let label: String
    let placeholder: String
    let prefix: String
    let suffix: String
    let color: Color

    init(text: Binding<String>, label: String, placeholder: String, prefix: String = "", suffix: String = "", color: Color = .blue) {
        self._text = text
        self.label = label
        self.placeholder = placeholder
        self.prefix = prefix
        self.suffix = suffix
        self.color = color
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(label)
                .font(.headline)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            ZStack(alignment: .leading) {
                // This is used so the unit moves with the text in the TextField
                HStack(alignment: .firstTextBaseline, spacing: 3) { // HIDDEN
                    Text(prefix).hidden()

                    TextField(text: $text) {
                        Text(text.isEmpty ? placeholder : text)
                    }
                    .fixedSize()
                    .hidden()

                    Text(suffix)
                        .font(.headline)
                        .opacity(text.isEmpty ? 0.4 : 1)
                }

                // VISIBLE
                HStack(alignment: .firstTextBaseline, spacing: 0) {
                    Text(prefix)
                        .opacity(text.isEmpty ? 0.4 : 1)

                    TextField(text: $text) {
                        Text(placeholder)
                            .foregroundColor(color.opacity(0.4))
                    }
                    .onChange(of: text) { _ in
                        text = String(text.prefix(3))
                    }
                }
            }
            .font(.system(.largeTitle, design: .rounded))
            .bold()
        }
        .padding(8)
        .background {
            RoundedRectangle(cornerRadius: 10)
                .opacity(0.2)
        }
        .foregroundColor(color)
    }
}

struct ValueField_Previews: PreviewProvider {
    static var previews: some View {
        ValueField(text: .constant(""), label: "Donation Amount", placeholder: "Tap", suffix: "mL", color: .orange)
            .padding(.horizontal)
            .frame(width: 200, height: 110)
            .previewDisplayName("ValueField")
            .previewLayout(.sizeThatFits)

        HStack {
            ValueField(text: .constant("7.2"), label: "Protein", placeholder: "0.0", suffix: "g/dL", color: .orange)
            ValueField(text: .constant(""), label: "Compensation", placeholder: "0", prefix: "$", color: .green)
        }
        .padding()
        .previewDisplayName("HStack ValueField")
        .previewLayout(.sizeThatFits)
    }
}
