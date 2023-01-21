//
//  Binding+Ext.swift
//  DonorTrack
//
//  Created by Hunter Dobbelmann on 1/15/23.
//

import SwiftUI

extension Binding where Value == String {
    // Limit the number of characters in a TextField
    func max(_ limit: Int) -> Self {
        if self.wrappedValue.count > limit {
            DispatchQueue.main.async {
                self.wrappedValue = String(self.wrappedValue.dropLast())
            }
        }

        return self
    }
}
