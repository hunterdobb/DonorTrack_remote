//
//  DonationEntity.swift
//  DonorTrack
//
//  Created by Hunter Dobbelmann on 1/13/23.
//

import CoreData
import SwiftUI

final public class DonationEntity: NSManagedObject, Identifiable {
    @NSManaged var amountDonated: Int16
    @NSManaged var compensation: Int16
    @NSManaged var cycleCount: Int16
    @NSManaged var startTime: Date
    @NSManaged var endTime: Date
    @NSManaged var protein: Double
    @NSManaged var notes: String
	@NSManaged public var allInfo: NSSet?

    var durationString: String {
        if endTime >= startTime {
            return (startTime...endTime).asDurationString()
        }

        return "Invalid Range"
    }

	@objc dynamic
	var monthString: String {
		let isSameYear = Calendar.current.isDate(startTime, equalTo: .now, toGranularity: .year)
		let yearText = isSameYear ? "" : ", \(startTime.formatted(.dateTime.year()))"

		return "\(startTime.formatted(.dateTime.month(.wide)))\(yearText)"
	}

    var avgCycleDurationString: String {
        if cycleCount != 0 {
            return Date.durationFormat.string(from: (endTime.timeIntervalSince(startTime)) / Double(cycleCount)) ?? "Error"
        }

        return "Error"
    }

	public override func awakeFromInsert() {
        super.awakeFromInsert()

        setPrimitiveValue(Date.now, forKey: "startTime")
        setPrimitiveValue(Date.now, forKey: "endTime")
        setPrimitiveValue(0, forKey: "cycleCount")
    }
}

extension DonationEntity {
    private static var donationsFetchRequest: NSFetchRequest<DonationEntity> {
        NSFetchRequest(entityName: "DonationEntity")
    }

    static func all() -> NSFetchRequest<DonationEntity> {
        let request = donationsFetchRequest
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \DonationEntity.startTime, ascending: false)
        ]
        return request
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
}

extension DonationEntity {
    // Means you don't need to set a property to hold the value, it can just return
    // and nothing will happen to it
    @discardableResult
    static func makePreview(count: Int, in context: NSManagedObjectContext) -> [DonationEntity] {
        var donations = [DonationEntity]()
        var date = Date.now

        for i in 0..<count {
            let isSecondDonationOfWeek = (i % 2 == 1)
            let donation = DonationEntity(context: context)

            let secondsInMinute = 60.0

            if i != 0 {
                if isSecondDonationOfWeek {
                    date = Calendar.current.date(byAdding: .day, value: 5, to: date)!
                } else {
                    date = Calendar.current.date(byAdding: .day, value: 2, to: date)!
                }
            }

            donation.amountDonated = Int16.random(in: 690...695)
            donation.compensation = isSecondDonationOfWeek ? 80 : 50
            donation.cycleCount = isSecondDonationOfWeek ? 9 : 8
            donation.startTime = date
            donation.endTime = donation.startTime + (Double.random(in: 32...45) * secondsInMinute)
            donation.protein = Double.random(in: 6.0...7.2)
            donation.notes = "This is an example donation for previews \(i)"

            donations.append(donation)
        }

        return donations
    }

    static func preview(context: NSManagedObjectContext = DataController.shared.viewContext) -> DonationEntity {
        makePreview(count: 1, in: context)[0]
    }

    static func empty(context: NSManagedObjectContext = DataController.shared.viewContext) -> DonationEntity {
        DonationEntity(context: context)
    }
}
