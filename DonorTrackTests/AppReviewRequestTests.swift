//
//  AppReviewRequestTests.swift
//  DonorTrackTests
//
//  Created by Hunter Dobbelmann on 3/30/23.
//

import XCTest
@testable import DonorTrack

final class AppReviewRequestTests: XCTestCase {
	private var userDefaults: UserDefaults!
	private var sut: ReviewRequestManager! // systemUnderTest

	override func setUp() {
		self.userDefaults = UserDefaults(suiteName: #file)
		self.sut = ReviewRequestManager(userDefaults: userDefaults)
	}

	override func tearDown() {
		userDefaults.removePersistentDomain(forName: #file)
		userDefaults = nil
		sut = nil
	}

	func testAppIsValidForRequestOnFreshLaunch() {
		XCTAssertTrue(sut.canAskForReview(donationCount: sut.limit),
					  "The user has reached the limit (\(sut.limit)) they should be prompted to review")
	}

	func testAppIsInvalidForRequestOnFreshLaunch() {
		let limit = 0
		XCTAssertFalse(sut.canAskForReview(donationCount: limit),
					   "The user hasn't reached the limit (\(sut.limit)) they shouldn't be prompted to review")
	}

	func testAppIsInvalidForRequestAfterLimitReached() {
		var limit = sut.limit
		XCTAssertTrue(sut.canAskForReview(donationCount: sut.limit),
					  "The user has reached the limit (\(sut.limit)) they should be prompted to review")

		limit *= 2
		XCTAssertFalse(sut.canAskForReview(donationCount: limit),
					  "The user should not be prompted to review in the same version.")
	}

	func testAppIsInvalidForRequestForNewVersion() {
		let oldVersion = "1.0"
		let newVersion = "1.1"

		var limit = sut.limit
		let canAskForReview = sut.canAskForReview(donationCount: limit,
												  lastReviewedVersion: nil,
												  currentVersion: oldVersion)
		XCTAssertTrue(canAskForReview,
					  "The user has hit the limit (\(sut.limit)) they should be prompted to review")


		limit *= 2
		let canAskForReviewNewVersion = sut.canAskForReview(donationCount: limit,
												  lastReviewedVersion: oldVersion,
												  currentVersion: newVersion)
		XCTAssertTrue(canAskForReviewNewVersion,
					  "The user has hit the limit (\(sut.limit)) and are on a new version, they should be prompted to review")


		limit *= 2
		let canAskForReviewSameVersion = sut.canAskForReview(donationCount: limit,
												  lastReviewedVersion: newVersion,
												  currentVersion: newVersion)
		XCTAssertFalse(canAskForReviewSameVersion,
					  "The user can't review the same version.")
	}

	func testAppIsValidForRequestForNewVersion() {
		let oldVersion = "1.0"
		let newVersion = "1.1"

		var limit = sut.limit
		let canAskForReview = sut.canAskForReview(donationCount: limit,
												  lastReviewedVersion: nil,
												  currentVersion: oldVersion)
		XCTAssertTrue(canAskForReview,
					  "The user has hit the limit (\(sut.limit)) they should be prompted to review")


		limit *= 2
		let canAskForReviewNewVersion = sut.canAskForReview(donationCount: limit,
												  lastReviewedVersion: oldVersion,
												  currentVersion: newVersion)
		XCTAssertTrue(canAskForReviewNewVersion,
					  "The user has hit the limit (\(sut.limit)) and are on a new version, they should be prompted to review")

	}
}
