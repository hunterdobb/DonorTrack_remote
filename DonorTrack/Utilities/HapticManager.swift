//
//  HapticManager.swift
//  DonorTrack
//
//  Created by Hunter Dobbelmann on 1/16/23.
//

import SwiftUI

class HapticManager {
    static let instance = HapticManager()

    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}
