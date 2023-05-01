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
    @MainActor
    class ViewModel: ObservableObject {
        private let context: NSManagedObjectContext
        let provider: DataController // I made this un-private to pass it into another view?

        @Published var showNotes = false

        @Published var donationToEdit: DonationEntity?

        @Published var searchConfig = SearchConfig()
        @Published var sort: Sort = .newestFirst

        init(provider: DataController, donation: DonationEntity? = nil) {
            self.provider = provider
            self.context = provider.viewContext
        }

		func groupDonationsByMonth(_ result: FetchedResults<DonationEntity>) -> [[DonationEntity]] {
			Dictionary(grouping: result) { (donation: DonationEntity) in
				donation.startTime.month
			}.values.sorted {
				if sort == .newestFirst {
					return $0[0].startTime > $1[0].startTime
				} else {
					return $0[0].startTime < $1[0].startTime
				}
			}
		}

		func totalEarnedAllTime(_ donations: FetchedResults<DonationEntity>) -> String {
			let compensations = donations.map { Int($0.compensation) }
			let total = compensations.reduce(0, +)
			return "$\(total)"
		}
    }
}
