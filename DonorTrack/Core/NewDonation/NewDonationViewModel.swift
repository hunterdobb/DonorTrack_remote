//
//  NewDonationViewModel.swift
//  DonorTrack
//
//  Created by Hunter Dobbelmann on 1/15/23.
//

import CoreData
import SwiftUI

// Extension is used for namespacing
// Make it only available to be used in NewDonationView
extension NewDonationView {
    @MainActor
    class ViewModel: ObservableObject {
        @Published var donation: DonationEntity
        private let context: NSManagedObjectContext
        private let provider: DonationsProvider

        @Published var proteinText = ""
        @Published var compensationText = ""
        @Published var amountText = ""
        @Published var cycleCount: Int16 = 0
        @Published var notes = ""
        
        @Published var startTime: Date?
        @Published var endTime: Date?

        @Published var donationState: DonationState = .idle
        @Published var actionButtonText = "Start Donation"
        @Published var actionButtonColor: Color = .blue

        @Published var showingAlert = false
        let alertTitle = "Fill out all the info before saving"

        var canUndoCycleCount: Bool {
            cycleCount > 0
        }

        enum DonationState: Int, Comparable {
            // Used for figuring out things like 'if donationState > .idle' meaning we're past the idle state.
            static func < (lhs: NewDonationView.ViewModel.DonationState, rhs: NewDonationView.ViewModel.DonationState) -> Bool {
                lhs.rawValue < rhs.rawValue
            }

            case idle = 0, started, finished
        }

        init(provider: DonationsProvider, donation: DonationEntity? = nil) {
            self.provider = provider
            self.context = provider.newContext
            self.donation = DonationEntity(context: self.context)
        }

        func save() throws {
            try context.save()
            print("Saved!")
        }

        func actionButtonTapped() {
            switch donationState {
            case .idle:
                startTime = Date.now
                donation.startTime = Date.now
                
                actionButtonColor = .pink
                actionButtonText = "Finish Donation"
                donationState = .started
                HapticManager.instance.impact(style: .rigid)
            case .started:
                endTime = Date.now
                donation.endTime = Date.now

                actionButtonColor = .mint
                actionButtonText = "Save Donation"
                donationState = .finished
            case .finished:
                if fieldsValidated() {
                    do {
                        try save()
                        resetView()
                    } catch {
                        print(error)
                    }
                } else {
                    showingAlert = true
                    print("Not valid")
                }
            }
        }

        private func startDonation() {

        }

        private func resetView() {
            donationState = .idle
            actionButtonText = "Start Donation"
            actionButtonColor = .blue
            amountText = ""
            proteinText = ""
            compensationText = ""
            cycleCount = 0
            notes = ""
            startTime = nil
            endTime = nil

            // Create new DonationEntity to edit
            print("\n\nBEFORE: \(String(describing: donation))\n\n")
            donation = DonationEntity(context: self.context)
            print("\n\nAFTER: \(String(describing: donation))\n\n")
        }

        private func fieldsValidated() -> Bool {
            !(amountText.isEmpty) && !(proteinText.isEmpty) && !(compensationText.isEmpty)
        }

        func incrementCycleCount() {
            cycleCount += 1
            donation.cycleCount = cycleCount
            HapticManager.instance.impact(style: .rigid)
        }

        func undoCycleCount() {
            if canUndoCycleCount {
                cycleCount -= 1
                donation.cycleCount = cycleCount
            }
            HapticManager.instance.impact(style: .rigid)
        }
    }
}
