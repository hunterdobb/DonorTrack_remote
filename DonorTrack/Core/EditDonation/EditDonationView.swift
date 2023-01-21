//
//  EditDonationView.swift
//  DonorTrack
//
//  Created by Hunter Dobbelmann on 1/18/23.
//

import SwiftUI

struct EditDonationView: View {
    @ObservedObject var vm: ViewModel

    @Environment(\.dismiss) private var dismiss

    @FocusState private var focusedField: FocusedField?

    @State private var showingAlert = false
    let alertTitle = "Fill out all the info before saving"

    enum FocusedField {
        case donationAmount, protein, compensation, notes, cycle
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Time") {

                    DatePicker("Start Time", selection: $vm.donation.startTime, displayedComponents: [.date, .hourAndMinute])
                    DatePicker("End Time", selection: $vm.donation.endTime, displayedComponents: [.date, .hourAndMinute])

                    LabeledContent {
                        Text(vm.donation.durationString)
                    } label: {
                        Text("Duration")
                    }
                }

                Section("Info") {
                    // Protein
                    DataField(text: $vm.proteinText, label: "Protein",
                              placeholder: String(format: "%.1f", vm.donation.protein),
                              color: .orange, suffix: "g/dL")
                    .keyboardType(.decimalPad)
                    .focused($focusedField, equals: .protein)
                    .onTapGesture { focusedField = .protein }
                    .onChange(of: vm.proteinText) { text in
                        guard Double(text) != nil else {
                            vm.proteinText = ""
                            return
                        }
                    }

                    // Compensation
                    DataField(text: $vm.compensationText, label: "Compensation",
                              placeholder: "\(vm.donation.compensation)",
                              color: .green, prefix: "$")
                    .keyboardType(.numberPad)
                    .focused($focusedField, equals: .compensation)
                    .onTapGesture { focusedField = .compensation }
                    .onChange(of: vm.compensationText) { text in
                        guard Int16(text) != nil else {
                            vm.compensationText = ""
                            return
                        }
                    }

                    // Amount Donated
                    DataField(text: $vm.amountText, label: "Amount Donated",
                              placeholder: "\(vm.donation.amountDonated)",
                              color: .cyan, suffix: "mL")
                    .keyboardType(.numberPad)
                    .focused($focusedField, equals: .donationAmount)
                    .onTapGesture {
                        focusedField = .donationAmount
                    }
                    .onChange(of: vm.amountText) { text in
                        guard Int16(text) != nil else {
                            vm.amountText = ""
                            return
                        }
                    }

                    // Cycle Count
                    DataField(text: $vm.cycleCountText, label: "Cycle Count",
                              placeholder: "\(vm.donation.cycleCount)", color: .blue)
                    .keyboardType(.numberPad)
                    .focused($focusedField, equals: .cycle)
                    .onTapGesture {
                        focusedField = .cycle
                    }
                    .onChange(of: vm.cycleCountText) { text in
                        guard Int16(text) != nil else {
                            vm.cycleCountText = ""
                            return
                        }
                    }
                }

                Section("Notes") {
                    TextField("Add notes here", text: $vm.donation.notes, axis: .vertical)
                        .focused($focusedField, equals: .notes)
                }
            }
            .navigationTitle(vm.isNew ? Text("Manual entry") : Text(vm.donation.startTime, style: .date))
            .navigationBarTitleDisplayMode(.inline)
            .alert(alertTitle, isPresented: $showingAlert) { }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        do {
                            try vm.save()
                            dismiss()
                        } catch EditDonationView.ViewModel.SaveError.notFilledIn {
                            showingAlert = true
                        } catch {
                            print(error)
                        }
                    }
                }

                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .scrollDismissesKeyboard(.interactively)
        }
    }
}

struct EditDonationView_Previews: PreviewProvider {
    static var previews: some View {
        // Preview without data
        let previewEmpty = DonationsProvider.shared
        NavigationStack {
            EditDonationView(vm: .init(provider: .shared))
                .environment(\.managedObjectContext, previewEmpty.viewContext)
        }
        .previewDisplayName("EditView Without Data")

        // Preview with data
        let previewProvider = DonationsProvider.shared
        NavigationStack {
            // This doesn't fully work bc in the vm we use provider.newContext, so they're accessing
            // seperate contexts.
            // As a work around I added the preview bool to use the provider.viewContext instead.
            // For it to fully work, I somehow need to create the preview data on the same newContext used
            // in the vm
            EditDonationView(vm: .init(provider: previewProvider, donation: .preview(context: previewProvider.viewContext), preview: true))
        }
        .previewDisplayName("EditView With Data")
    }
}
