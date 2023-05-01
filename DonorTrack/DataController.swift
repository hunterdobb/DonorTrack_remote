//
//  DataController.swift
//  DonorTrack
//
//  Created by Hunter Dobbelmann on 1/13/23.
//

import CoreData
import SwiftUI

// provider.viewContext is the main context

final class DataController {
    static let shared = DataController()

    private let container: NSPersistentContainer

    var viewContext: NSManagedObjectContext {
        container.viewContext
    }

    var newContext: NSManagedObjectContext {
        container.newBackgroundContext()
    }

    private init() {
        container = NSPersistentContainer(name: "DonationsDataModel")

        if EnvironmentValues.isPreview || Thread.current.isRunningXCTest {
            container.persistentStoreDescriptions.first?.url = .init(fileURLWithPath: "/dev/null")
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.loadPersistentStores { _, error in
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

extension Thread {
    var isRunningXCTest: Bool {
    for key in self.threadDictionary.allKeys {
      guard let keyAsString = key as? String else {
        continue
      }

      if keyAsString.split(separator: ".").contains("xctest") {
        return true
      }
    }
    return false
  }
}
