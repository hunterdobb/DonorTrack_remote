//
//  DonationDetailView.swift
//  DonorTrack
//
//  Created by Hunter Dobbelmann on 1/13/23.
//

import SwiftUI

struct DonationDetailView: View {
    @ObservedObject var donation: DonationEntity
//	let provider: DataController
	@EnvironmentObject var dataController: DataController

    @State private var donationToEdit: DonationEntity?

    var body: some View {
        List {
            Section("Time", content: timeSection)
            Section("Info", content: infoSection)
            Section("Cycles", content: cyclesSection)
            Section("Notes", content: notesSection)
        }
        .navigationTitle(Text(donation.donationStartTime, style: .date))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { editButton }
        .sheet(item: $donationToEdit) {
			donationToEdit = nil // onDismiss
        } content: { donation in
			EditDonationView(dataController: dataController, donation: donation)
//            EditDonationView(vm: .init(provider: provider, donation: donation))
        }
    }
}

struct DonationDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            let previewProvider = DataController.shared
			DonationDetailView(donation: .example)
				.environmentObject(DataController.preview)
        }
    }
}

extension DonationDetailView {
	@ViewBuilder
	private func timeSection() -> some View {
		LabeledContent {
			Text("\(donation.donationStartTime, style: .time) - \(donation.donationEndTime, style: .time)")
		} label: {
//			HStack {
//				Image(systemName: "clock")
				Text("Time")
//			}
		}

		LabeledContent {
			Text(donation.durationString)
		} label: {
//			HStack {
//				Image(systemName: "timer")
				Text("Duration")
//			}
		}
	}

	@ViewBuilder
	private func infoSection() -> some View {
		LabeledContent {
			Text("\(donation.protein, specifier: "%.1f") g/dL")
		} label: {
//			HStack {
//				Image(systemName: "drop.triangle")
				Text("Protein")
//			}
		}

		LabeledContent {
			Text("$\(donation.compensation)")
		} label: {
//			HStack {
//				Image(systemName: "dollarsign.circle")
				Text("Compensation")
//			}
		}

		LabeledContent {
			Text("\(donation.amountDonated) mL")
		} label: {
//			HStack {
//				Image(systemName: "drop.circle")
				Text("Amount Donated")
//			}
		}
	}

	@ViewBuilder
	private func cyclesSection() -> some View {
		LabeledContent {
			Text("\(donation.cycleCount) Cycles")
		} label: {
			Text("Count")
		}

		if donation.cycleCount > 0 {
			LabeledContent {
				Text(donation.avgCycleDurationString)
			} label: {
				Text("Avg. Cycle Duration")
			}

			LabeledContent {
				Text("\((donation.amountDonated) / donation.cycleCount) mL")
			} label: {
				Text("Avg. Cycle Amount")
			}
		}
	}

	@ViewBuilder
	private func notesSection() -> some View {
		Text(donation.donationNotes)
			.foregroundColor(.secondary)
	}

	@ViewBuilder
	private var editButton: some View {
		Button("Edit") { donationToEdit = donation }
	}
}
