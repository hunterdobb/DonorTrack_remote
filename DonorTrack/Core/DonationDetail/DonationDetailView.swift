//
//  DonationDetailView.swift
//  DonorTrack
//
//  Created by Hunter Dobbelmann on 1/13/23.
//

import SwiftUI

struct DonationDetailView: View {
    @ObservedObject var donation: DonationEntity

    @State private var donationToEdit: DonationEntity?
    let provider: DonationsProvider

    var body: some View {
        List {
            Section("Time") {
                LabeledContent {
                    Text("\(donation.startTime, style: .time) - \(donation.endTime, style: .time)")
                } label: {
                    Text("Time")
                }

                LabeledContent {
                    Text(donation.durationString)
                } label: {
                    Text("Duration")
                }
            }

            Section("Info") {
                LabeledContent {
                    Text("\(donation.protein, specifier: "%.1f") g/dL")
                } label: {
                    Text("Protein")
                }

                LabeledContent {
                    Text("$\(donation.compensation)")
                } label: {
                    Text("Compensation")
                }

                LabeledContent {
                    Text("\(donation.amountDonated) mL")
                } label: {
                    Text("Amount Donated")
                }
            }

            Section("Cycles") {
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

            Section("Notes") {
                Text(donation.notes)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle(Text(donation.startTime, style: .date))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem {
                Button("Edit") {
                    donationToEdit = donation
                }
            }
        }
        .sheet(item: $donationToEdit) {
            // onDismiss
            donationToEdit = nil
        } content: { donation in
            EditDonationView(vm: .init(provider: provider, donation: donation))
        }
    }
}

struct DonationDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            let previewProvider = DonationsProvider.shared
            DonationDetailView(donation: .preview(context: previewProvider.viewContext), provider: previewProvider)
        }
    }
}
