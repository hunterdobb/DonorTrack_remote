//
//  EditDonationViewModel.swift
//  DonorTrack
//
//  Created by Hunter Dobbelmann on 1/18/23.
//

import CoreData
import SwiftUI

extension EditDonationView {
    @MainActor
    class ViewModel: ObservableObject {
        @Published var donation: DonationEntity
        @Published var donationDay: Date
        let isNew: Bool

        enum SaveError: Error {
            case notFilledIn, invalidDateRange
        }

        private let context: NSManagedObjectContext
        private let provider: DonationsProvider

        @Published var proteinText = ""
        @Published var compensationText = ""
        @Published var amountText = ""
        @Published var cycleCountText = ""
        @Published var notes = ""

//        @Published var showingAlert = false
//        let alertTitle = "Fill out all the info before saving"

        init(provider: DonationsProvider, donation: DonationEntity? = nil, preview: Bool = false) {
            self.provider = provider

            if preview {
                self.context = provider.viewContext
            } else {
                self.context = provider.newContext
            }
            
            if let donation,
               let existingDonationCopy = provider.exists(donation, in: context) {
                self.donation = existingDonationCopy
                self.isNew = false
                donationDay = existingDonationCopy.startTime
                populateFields()
            } else {
                self.donation = DonationEntity(context: self.context)
                donationDay = Date()
                self.isNew = true
            }

        }

        func updateDay(with newValue: Date) {
            let calendar = Calendar.current
            let newComponents = calendar.dateComponents([.month, .day, .year], from: newValue)

            let existingStartComponents = calendar.dateComponents([.hour, .minute, .second], from: donation.startTime)
            var newStartTime = DateComponents()
            newStartTime.month = newComponents.month
            newStartTime.day = newComponents.day
            newStartTime.year = newComponents.year
            newStartTime.hour = existingStartComponents.hour
            newStartTime.minute = existingStartComponents.minute
            newStartTime.second = existingStartComponents.second

            let existingEndComponents = calendar.dateComponents([.hour, .minute, .second], from: donation.endTime)
            var newEndTime = DateComponents()
            newEndTime.month = newComponents.month
            newEndTime.day = newComponents.day
            newEndTime.year = newComponents.year
            newEndTime.hour = existingEndComponents.hour
            newEndTime.minute = existingEndComponents.minute
            newEndTime.second = existingEndComponents.second

            donation.startTime = calendar.date(from: newStartTime)!
            donation.endTime = calendar.date(from: newEndTime)!
        }

        private func fieldsValidated() -> Bool {
            !(amountText.isEmpty) &&
            !(proteinText.isEmpty) &&
            !(compensationText.isEmpty) &&
            !(cycleCountText.isEmpty)
        }

        private func populateFields() {
//            proteinText = String(donation.protein.rounded())
//            compensationText = String(donation.compensation)
//            amountText = String(donation.amountDonated)
//            cycleCountText = String(donation.cycleCount)
            notes = donation.notes
        }

        // Used when creating manual donation
        private func setData() {
            if let protein = Double(proteinText),
               let compensation = Int16(compensationText),
               let amountDonated = Int16(amountText),
               let cycleCount = Int16(cycleCountText) {
                donation.protein = protein
                donation.compensation = compensation
                donation.amountDonated = amountDonated
                donation.cycleCount = cycleCount
            }
        }

        // Used when updating existing donation
        func updateData() {
            if !proteinText.isEmpty {
                if let protein = Double(proteinText) {
                    donation.protein = protein
                }
            }

            if !compensationText.isEmpty {
                if let compensation = Int16(compensationText) {
                    donation.compensation = compensation
                }
            }

            if !amountText.isEmpty {
                if let amountDonated = Int16(amountText) {
                    donation.amountDonated = amountDonated
                }
            }

            if !cycleCountText.isEmpty {
                if let cycleCount = Int16(cycleCountText) {
                    donation.cycleCount = cycleCount
                }
            }
        }

        func save() throws {
            if isNew {
                if fieldsValidated() {
                    if donation.startTime < donation.endTime {
                        setData()
                        try provider.persist(in: context)
                    } else {
                        throw SaveError.invalidDateRange
                    }
                } else {
                    throw SaveError.notFilledIn
                }
            } else {
                updateData()
                try provider.persist(in: context)
            }

        }
    }
}
