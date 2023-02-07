//
//  ModelTests.swift
//  DonorTrackTests
//
//  Created by Hunter Dobbelmann on 1/23/23.
//

import XCTest
@testable import DonorTrack

final class ModelTests: XCTestCase {
    private var provider: DonationsProvider!

    override func setUp() {
        provider = .shared
    }

    override func tearDown() {
        provider = nil
    }

    func testDonationIsEmpty() {
        let donation = DonationEntity.empty(context: provider.viewContext)
        XCTAssertEqual(donation.amountDonated, 0)
        XCTAssertEqual(donation.protein, 0)
        XCTAssertEqual(donation.compensation, 0)
        XCTAssertEqual(donation.cycleCount, 0)
        XCTAssertEqual(donation.notes, "")
        XCTAssertTrue(Calendar.current.isDateInToday(donation.startTime))
        XCTAssertTrue(Calendar.current.isDateInToday(donation.endTime))
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
        let donation = DonationEntity.empty()
        let oneMinTwentySeconds = 80.0

        donation.endTime = donation.startTime.advanced(by: oneMinTwentySeconds)
        XCTAssertEqual(donation.durationString, "1m 20s")
    }

    func testDurationStringIsNotValid() {
        let donation = DonationEntity.empty()
        let oneMinTwentySeconds = 80.0

        donation.startTime = Date.now.advanced(by: oneMinTwentySeconds)
        XCTAssertEqual(donation.durationString, "Invalid Range")
    }

    func testAvgCycleDurationStringIsValid() {
        let donation = DonationEntity.empty()
        let fiveMinsThirtyTwoSeconds = 332.0

        // 332 / 5 = 66.4 = 1m 6s
        donation.cycleCount = 5
        donation.endTime = donation.endTime.advanced(by: fiveMinsThirtyTwoSeconds)
        XCTAssertEqual(donation.avgCycleDurationString, "1m 6s")
    }

    func testAvgCycleDurationStringIsNotValid() {
        let donation = DonationEntity.empty()
        donation.cycleCount = 0
        XCTAssertEqual(donation.avgCycleDurationString, "Error")
    }

    func testMakeDonationsPreviewIsValid() {
        let count = 50
        let donations = DonationEntity.makePreview(count: count, in: provider.viewContext)

        for i in 0..<donations.count {
            let donation = donations[i]

            XCTAssertTrue(donation.amountDonated >= 690 && donation.amountDonated <= 695)
            XCTAssertTrue(donation.cycleCount == 8 || donation.cycleCount == 9)
            XCTAssertTrue(donation.compensation == 50 || donation.compensation == 80)
            XCTAssertTrue(donation.protein >= 6.0 && donation.protein <= 7.2)
            XCTAssertEqual(donation.notes, "This is an example donation for previews \(i)")
        }
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
