//
//  HapticManager.swift
//  DonorTrack
//
//  Created by Hunter Dobbelmann on 1/16/23.
//

import SwiftUI
//import UIKit

fileprivate final class HapticManager {
    static let instance = HapticManager()

	private init() {}

	private let feedback = UINotificationFeedbackGenerator()

    func triggerImpact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }

	func triggerFeedback(_ notification: UINotificationFeedbackGenerator.FeedbackType) {
		feedback.notificationOccurred(notification)
	}
}

func hapticImpact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
	if UserDefaults.standard.bool(forKey: UDKeys.hapticsEnabled) {
		HapticManager.instance.triggerImpact(style: style)
	}
}

func hapticNotification(_ notification: UINotificationFeedbackGenerator.FeedbackType) {
	if UserDefaults.standard.bool(forKey: UDKeys.hapticsEnabled) {
		HapticManager.instance.triggerFeedback(notification)
	}
}
