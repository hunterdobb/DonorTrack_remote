//
//  DonationsListViewModel.swift
//  DonorTrack
//
//  Created by Hunter Dobbelmann on 1/17/23.
//

import CoreData
import SwiftUI

struct SearchConfig: Equatable {
    enum Filter {
        case all, lowProtein
    }

    var query: String = ""
    var filter: Filter = .all
}

enum Sort {
    case newestFirst, oldestFirst
}

extension DonationsListView {
	@dynamicMemberLookup
    @MainActor
    class ViewModel: ObservableObject {
        private let context: NSManagedObjectContext
        var dataController: DataController // I made this un-private to pass it into another view?

        @Published var showNotes = false
        @Published var donationToEdit: DonationEntity?
        @Published var searchConfig = SearchConfig()
        @Published var sort: Sort = .newestFirst

        init(dataController: DataController) {
            self.dataController = dataController
            self.context = dataController.viewContext
        }

		subscript<Value>(dynamicMember keyPath: KeyPath<DataController, Value>) -> Value {
			dataController[keyPath: keyPath]
		}

		subscript<Value>(dynamicMember keyPath: ReferenceWritableKeyPath<DataController, Value>) -> Value {
			get { dataController[keyPath: keyPath] }
			set { dataController[keyPath: keyPath] = newValue }
		}

//		func newDonationToEdit() {
//			let tempContext = NSManagedObjectContext(.mainQueue)
//			tempContext.parent = dataController.container.viewContext
//			print(tempContext)
//			donationToEdit = DonationEntity(context: tempContext)
////			donationToEdit = dataController.newTemporaryDonation()
//		}

		func groupDonationsByMonth(_ result: FetchedResults<DonationEntity>) -> [[DonationEntity]] {
			Dictionary(grouping: result) { (donation: DonationEntity) in
				donation.donationStartTime.month
			}.values.sorted {
				if sort == .newestFirst {
					return $0[0].donationStartTime > $1[0].donationStartTime
				} else {
					return $0[0].donationStartTime < $1[0].donationStartTime
				}
			}
		}

		func totalEarnedAllTime(_ donations: FetchedResults<DonationEntity>) -> Double {
			let compensations = donations.map { Int($0.compensation) }
			let total = compensations.reduce(0, +)
			return Double(total)
		}

		func delete(_ offsets: IndexSet) {
			let donations = (try? dataController.container.viewContext.fetch(DonationEntity.all())) ?? []

			for offset in offsets {
				let item = donations[offset]
				dataController.delete(item)
			}
		}
    }
}
