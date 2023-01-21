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
    let unit: String
    let color: Color

    init(text: Binding<String>, label: String, placeholder: String, unit: String = "", color: Color = .blue) {
        self._text = text
        self.label = label
        self.placeholder = placeholder
        self.unit = unit
        self.color = color
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(label)
                .font(.headline)

            ZStack(alignment: .leading) {
                // This is used so the unit moves with the text in the TextField
                HStack(alignment: .firstTextBaseline, spacing: 5) {
                    TextField("", text: $text) // hidden
                        .placeholder(text.isEmpty, alignment: .leading) {
                            Text(text.isEmpty ? placeholder : text) // hidden
                        }
                        .fixedSize()
                        .hidden()

                    Text(unit)
                        .font(.headline)
                        .opacity(text.isEmpty ? 0.5 : 1)
                }

                TextField("", text: $text) // visible
                    .onChange(of: text, perform: { _ in
                        text = String(text.prefix(3))
                    })
                    .placeholder(text.isEmpty, alignment: .leading) {
                        Text(placeholder)
                            .opacity(0.5)
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
        ValueField(text: .constant(""), label: "Donation Amount", placeholder: "Tap", unit: "mL", color: .orange)
            .padding(.horizontal)
            .frame(width: 200, height: 110)
            .previewDisplayName("ValueField")
            .previewLayout(.sizeThatFits)

        HStack {
            ValueField(text: .constant("7.2"), label: "Protein", placeholder: "0.0", unit: "g/dL", color: .orange)
            ValueField(text: .constant(""), label: "Compensation", placeholder: "$0")
        }
        .padding()
        .previewDisplayName("HStack ValueField")
        .previewLayout(.sizeThatFits)
    }
}
