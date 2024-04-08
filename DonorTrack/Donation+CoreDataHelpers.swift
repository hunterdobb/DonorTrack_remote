//
//  Donation+CoreDataHelpers.swift
//  DonorTrack
//
//  Created by Hunter Dobbelmann on 4/6/24.
//

import CoreData
import Foundation

extension DonationEntity {
	var donationStartTime: Date {
		get { startTime ?? .now }
		set { startTime = newValue }
	}

	var donationEndTime: Date {
		get { endTime ?? .now }
		set { endTime = newValue }
	}

	var donationAllInfo: [DonationInfo] {
		let results = allInfo?.allObjects as? [DonationInfo] ?? []
		return results/*.sorted()*/
	}

	var donationNotes: String {
		get { notes ?? "" }
		set { notes = newValue }
	}

	var durationString: String {
		if donationEndTime >= donationStartTime {
			return (donationStartTime...donationEndTime).asDurationString()
		}

		return "Invalid Range"
	}

	var avgCycleDurationString: String {
		if cycleCount != 0 {
			return Date.durationFormat.string(from: (donationEndTime.timeIntervalSince(donationStartTime)) / Double(cycleCount)) ?? "Error"
		}

		return "Error"
	}

	static var example: DonationEntity {
		let controller = DataController(inMemory: true)
		let viewContext = controller.container.viewContext

		let donation = DonationEntity(context: viewContext)
		donation.amountDonated = Int16.random(in: 690...695)
		donation.compensation = 50
		donation.cycleCount = 8
		donation.startTime = .now
		donation.endTime = .now + (Double.random(in: 32...45) * 60)
		donation.protein = Double.random(in: 6.0...7.2)
		donation.notes = "This is an example donation for previews"
		return donation
	}

	static func filter(with config: SearchConfig) -> NSPredicate {
		switch config.filter {
		case .all:
			return config.query.isEmpty ? NSPredicate(value: true) : NSPredicate(format: "notes CONTAINS[cd] %@", config.query)
		case .lowProtein:
			return config.query.isEmpty ? NSPredicate(format: "protein <= 6.3") :
			NSPredicate(format: "notes CONTAINS[cd] %@ AND protein <= 6.3", config.query)
		}
	}

	static func sort(order: Sort) -> [NSSortDescriptor] {
		[NSSortDescriptor(keyPath: \DonationEntity.startTime, ascending: order == .oldestFirst)]
	}

	static func all() -> NSFetchRequest<DonationEntity> {
		let request = fetchRequest()
		request.sortDescriptors = [
			NSSortDescriptor(keyPath: \DonationEntity.startTime, ascending: false)
		]
		return request
	}
}
