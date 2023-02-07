//
//  DonationsListViewModel.swift
//  DonorTrack
//
//  Created by Hunter Dobbelmann on 1/17/23.
//

import CoreData
import Foundation

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
        let provider: DonationsProvider // I made this un-private to pass it into another view?

        @Published var showNotes = false

        @Published var donationToEdit: DonationEntity?

        @Published var searchConfig = SearchConfig()
        @Published var sort: Sort = .newestFirst

        init(provider: DonationsProvider, donation: DonationEntity? = nil) {
            self.provider = provider
            self.context = provider.viewContext
        }
    }
}
