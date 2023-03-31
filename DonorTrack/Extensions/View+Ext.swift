//
//  View+Ext.swift
//  DonorTrack
//
//  Created by Hunter Dobbelmann on 1/14/23.
//

import Foundation
import SwiftUI

extension View {
    // Add custom placeholder to TextField
    func placeholder<Content: View>(
        _ shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {

        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}
