//
//  NewDonationViewModel.swift
//  DonorTrack
//
//  Created by Hunter Dobbelmann on 1/15/23.
//

import ActivityKit
import CoreData
import SwiftUI


@available(iOS 16.2, *)
class NewDonationActivity: ObservableObject {
	// TODO: I need to look up how to do it properly.

	static let shared = NewDonationActivity()

	@Published var activity: Activity<NewDonationAttributes>? = nil
}

// Extension is used for name-spacing
// Makes vm only available to be used in NewDonationView
extension NewDonationView {
	@MainActor
    class ViewModel: ObservableObject {
        @Published var donation: DonationEntity
        private var context: NSManagedObjectContext
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

		@Published var isSaved = false

        // Alerts
        @Published var showingNotFilledInAlert = false
        @Published var showingFinishConfirmationAlert = false
        @Published var showingResetConfirmationAlert = false

        // Should be set before showing each alert
        var alertTitle = ""
        var alertMessage = ""

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

		@EnvironmentObject private var reviewsManager: ReviewRequestManager

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
			case .idle: // start
				startTime = .now
				donation.startTime = .now

				startLiveActivity()
				
				actionButtonColor = .pink
				actionButtonText = "Finish Donation"
				donationState = .started
				hapticImpact(.rigid)

			case .started: // finish
				alertTitle = "Finished?"
				showingFinishConfirmationAlert = true
				// finishDonation() is called from view

			case .finished: // save
				if fieldsValidated() {
					do {
						try save()
						isSaved = true
						resetView()
					} catch {
						print(error)
					}
				} else {
					alertTitle = "Fill out all the info before saving"
					showingNotFilledInAlert = true
					print("Not valid")
				}
			}
        }

		private func startLiveActivity() {
			if #available(iOS 16.2, *) {
				let activityAttributes = NewDonationAttributes()
				let activityContent = NewDonationAttributes.NewDonationStatus(startTime: .now, cycleCount: cycleCount)

				do {
					NewDonationActivity.shared.activity =  try Activity.request(attributes: activityAttributes, contentState: activityContent, pushType: nil)
				} catch {
					print(error.localizedDescription)
				}
			}
		}

		private func endLiveActivity() {
			if #available(iOS 16.2, *) {
				guard let startTime else { return }
				let finishedDonationStatus = NewDonationAttributes.NewDonationStatus(startTime: startTime, cycleCount: cycleCount)
				let finalContent = ActivityContent(state: finishedDonationStatus, staleDate: nil)

				Task {
					for activity in Activity<NewDonationAttributes>.activities {
						await activity.end(finalContent, dismissalPolicy: .immediate)
					}
				}
			}
		}

		@available(iOS 16.2, *)
		private func updateLiveActivity() {
			guard let startTime else { return }
			let updatedDonationStatus = NewDonationAttributes.NewDonationStatus(startTime: startTime, cycleCount: cycleCount)
			let updatedContent = ActivityContent(state: updatedDonationStatus, staleDate: nil)

			Task {
				await NewDonationActivity.shared.activity?.update(updatedContent)
			}
		}

        // Called from view
        func finishDonation() {
			endTime = .now
			donation.endTime = .now

			endLiveActivity()

            actionButtonColor = .mint
            actionButtonText = "Save Donation"
            donationState = .finished
        }

        func resetView() {
			endLiveActivity()
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
            // We have to update the context so we have new data to work with
            // If we don't do this, donations that we reset will still exist and get saved when we call context.save()
            // This is bc we were making new DonationEntity's in the same context
            context = provider.newContext
            donation = DonationEntity(context: context)
        }

        private func fieldsValidated() -> Bool {
            !(amountText.isEmpty) && !(proteinText.isEmpty) && !(compensationText.isEmpty)
        }

        func incrementCycleCount() {
            cycleCount += 1
            donation.cycleCount = cycleCount

			if #available(iOS 16.2, *) {
				updateLiveActivity()
			}

			hapticImpact(.rigid)
        }

        func undoCycleCount() {
            if canUndoCycleCount {
                cycleCount -= 1
                donation.cycleCount = cycleCount

				if #available(iOS 16.2, *) {
					updateLiveActivity()
				}
            }

			hapticImpact(.rigid)
        }
    }
}
