//
//  DonationsProvider.swift
//  DonorTrack
//
//  Created by Hunter Dobbelmann on 1/13/23.
//

import CoreData
import SwiftUI

// provider.viewContext is the main context

final class DonationsProvider {
    static let shared = DonationsProvider()

    private let persistentContainer: NSPersistentContainer

    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    var newContext: NSManagedObjectContext {
        persistentContainer.newBackgroundContext()
    }

    private init() {
        persistentContainer = NSPersistentContainer(name: "DonationsDataModel")

        if EnvironmentValues.isPreview {
            persistentContainer.persistentStoreDescriptions.first?.url = .init(fileURLWithPath: "/dev/null")
        }

        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
        persistentContainer.loadPersistentStores { _, error in
            if let error {
                fatalError("Unable to load store with error: \(error)")
            }
        }
    }

    func exists(_ donation: DonationEntity,
                in context: NSManagedObjectContext) -> DonationEntity? {
        try? context.existingObject(with: donation.objectID) as? DonationEntity
    }

    func delete(_ donation: DonationEntity,
                in context: NSManagedObjectContext) throws {
        if let existingDonation = exists(donation, in: context) {
            context.delete(existingDonation)
            Task(priority: .background) {
                try await context.perform {
                    try context.save()
                }
            }
        }
    }

    func persist(in context: NSManagedObjectContext) throws {
        if context.hasChanges {
            try context.save()
        }
    }
}

extension EnvironmentValues {
    static var isPreview: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
}
