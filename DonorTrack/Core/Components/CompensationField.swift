//
//  CompensationField.swift
//  DonorTrack
//
//  Created by Hunter Dobbelmann on 1/14/23.
//

import SwiftUI

import SwiftUI

struct CompensationField: View {
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Compensation")
                .font(.headline)

            HStack(alignment: .firstTextBaseline, spacing: 0) {
                Text("$")
                    .opacity(text.isEmpty ? 0.5 : 1)

                TextField("", text: $text, onCommit: {
                    print("comp commit")
                }) // visible
                    .onChange(of: text, perform: { _ in
                        text = String(text.prefix(3))
                    })
                    .placeholder(text.isEmpty) {
                        Text("0")
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
        .foregroundColor(.green)
    }
}

struct CompensationField_Previews: PreviewProvider {
    static var previews: some View {
        CompensationField(text: .constant("90"))
            .padding()
    }
}
