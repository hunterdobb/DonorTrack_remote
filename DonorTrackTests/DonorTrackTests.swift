//
//  DonorTrackTests.swift
//  DonorTrackTests
//
//  Created by Hunter Dobbelmann on 4/6/24.
//

import CoreData
import XCTest

@testable import DonorTrack

class BaseTestCase: XCTestCase {
	var dataController: DataController!
	var managedObjectContext: NSManagedObjectContext!

	override func setUpWithError() throws {
		dataController = DataController(inMemory: true)
		managedObjectContext = dataController.viewContext
	}
}
