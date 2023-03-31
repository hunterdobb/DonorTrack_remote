//
//  ReviewsRequestManager.swift
//  DonorTrack
//
//  Created by Hunter Dobbelmann on 3/30/23.
//

import Foundation

final class ReviewRequestManager: ObservableObject {
	@Published private(set) var donationCount: Int

	private let userDefaults: UserDefaults
	private(set) var reviewLink = URL(string: "https://apps.apple.com/app/id1667108011?action=write-review")
	
	let limit = 10

	init(userDefaults: UserDefaults = .standard) {
		self.userDefaults = userDefaults
		donationCount = userDefaults.integer(forKey: UDKeys.donationCountKey)
	}

	/// Determines if the user can be prompted to review the app.
	/// - Parameters:
	///   - donationCount: The number of donations the user has completed.
	///   - lastReviewedVersion: Used for testing (dependency injection)
	///   - currentVersion: Used for testing (dependency injection)
	/// - Returns: true if they should be prompted, false if not.
	func canAskForReview(
		donationCount: Int,
		lastReviewedVersion: String? = nil,
		currentVersion: String? = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
	) -> Bool {
		let lastVersionPromptedForReview = lastReviewedVersion ?? userDefaults.string(forKey: UDKeys.lastVersionPromptedForReviewKey)

		// Get the current bundle version for the app. (Similar to Apple sample app, although we're passing
		// the currentVersion in as a function parameter)
		guard let currentVersion = currentVersion
			else { fatalError("Expected to find a bundle version in the info dictionary.") }

		let hasReachedThreshold = donationCount.isMultiple(of: limit) && (donationCount != 0)
		let isNewVersion = currentVersion != lastVersionPromptedForReview

		guard hasReachedThreshold && isNewVersion else { return false }

		// Delay for two seconds to avoid interrupting the person using the app.
		// Use the equation n * 10^9 to convert seconds to nanoseconds. (From Apple's sample app)
//		try? await Task.sleep(nanoseconds: UInt64(2e9))

		userDefaults.set(currentVersion, forKey: UDKeys.lastVersionPromptedForReviewKey)
		return true
	}

	func incrementDonationCount() {
		donationCount += 1
		userDefaults.set(donationCount, forKey: UDKeys.donationCountKey)
	}
}
