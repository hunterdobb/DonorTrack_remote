//
//  ModelTests.swift
//  DonorTrackTests
//
//  Created by Hunter Dobbelmann on 1/23/23.
//

import XCTest
@testable import DonorTrack

final class ModelTests: BaseTestCase {
//    private var provider: DataController!
//
//    override func setUp() {
//        provider = .shared
//    }
//
//    override func tearDown() {
//        provider = nil
//    }

    func testDonationIsEmpty() {
//        let donation = DonationEntity.empty(context: provider.viewContext)
		let donation = dataController.newDonation()
        XCTAssertEqual(donation.amountDonated, 0)
        XCTAssertEqual(donation.protein, 0)
        XCTAssertEqual(donation.compensation, 0)
        XCTAssertEqual(donation.cycleCount, 0)
        XCTAssertEqual(donation.donationNotes, "")
        XCTAssertTrue(Calendar.current.isDateInToday(donation.donationStartTime))
        XCTAssertTrue(Calendar.current.isDateInToday(donation.donationEndTime))
    }

    // I don't have an isValid function on my model
//    func testDonationIsNotValid() {
//
//    }
//
//    func testDonationIsValid() {
//
//    }

    func testDurationStringIsValid() {
		let donation = dataController.newDonation()
        let oneMinTwentySeconds = 80.0

        donation.donationEndTime = donation.donationStartTime.advanced(by: oneMinTwentySeconds)
        XCTAssertEqual(donation.durationString, "1m 20s")
    }

    func testDurationStringIsNotValid() {
        let donation = dataController.newDonation()
        let oneMinTwentySeconds = 80.0

        donation.startTime = Date.now.advanced(by: oneMinTwentySeconds)
        XCTAssertEqual(donation.durationString, "Invalid Range")
    }

    func testAvgCycleDurationStringIsValid() {
        let donation = dataController.newDonation()
        let fiveMinsThirtyTwoSeconds = 332.0

        // 332 / 5 = 66.4 = 1m 6s
        donation.cycleCount = 5
        donation.endTime = donation.donationEndTime.advanced(by: fiveMinsThirtyTwoSeconds)
        XCTAssertEqual(donation.avgCycleDurationString, "1m 6s")
    }

    func testAvgCycleDurationStringIsNotValid() {
        let donation = dataController.newDonation()
        donation.cycleCount = 0
        XCTAssertEqual(donation.avgCycleDurationString, "Error")
    }

    func testMakeDonationsPreviewIsValid() {
        let count = 50
		dataController.createSampleData(count: count)

		XCTAssertEqual(
			dataController.count(for: DonationEntity.fetchRequest()), count,
			"There should be \(count) sample donations"
		)
    }

    func testFilterLowProteinDonationsRequestIsValid() {
        let request = DonationEntity.filter(with: .init(filter: .lowProtein))
        XCTAssertEqual("protein <= 6.3", request.predicateFormat)
    }

    func testFilterAllDonationsRequestIsValid() {
        let request = DonationEntity.filter(with: .init(filter: .all))
        XCTAssertEqual("TRUEPREDICATE", request.predicateFormat)
    }

    func testFilterAllWithQueryDonationsRequestIsValid() {
        let query = "test"
        let request = DonationEntity.filter(with: .init(query: query))
        XCTAssertEqual("notes CONTAINS[cd] \"\(query)\"", request.predicateFormat)
    }

    func testFilterLowProteinWithQueryDonationsRequestIsValid() {
        let query = "test"
        let request = DonationEntity.filter(with: .init(query: query, filter: .lowProtein))
        XCTAssertEqual("notes CONTAINS[cd] \"\(query)\" AND protein <= 6.3", request.predicateFormat)
    }

}
