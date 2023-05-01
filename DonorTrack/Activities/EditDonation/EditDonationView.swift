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
    @State private var alertTitle = ""

    enum FocusedField {
        case donationAmount, protein, compensation, notes, cycle
    }

    var body: some View {
        NavigationStack {
            List {
				Section("Time", content: timeSection)
				Section("Info", content: infoSection)
                Section("Notes", content: notesSection)
            }
            .navigationTitle(vm.isNew ? Text("Manual Entry") : Text("Edit Donation"))
            .navigationBarTitleDisplayMode(.inline)
			.scrollDismissesKeyboard(.interactively)
			.toolbar { cancelAction; doneAction }
        }
		.onAppear { vm.donationDay = vm.donation.startTime }
		.onReceive(vm.$donationDay) { newDate in vm.updateDay(using: newDate) }
		.alert(alertTitle, isPresented: $showingAlert) { }
    }
}

struct EditDonationView_Previews: PreviewProvider {
    static var previews: some View {
        // Preview without data
        let previewEmpty = DataController.shared
        NavigationStack {
            EditDonationView(vm: .init(provider: .shared))
                .environment(\.managedObjectContext, previewEmpty.viewContext)
        }
        .previewDisplayName("EditView Without Data")

        // Preview with data
        let previewProvider = DataController.shared
        NavigationStack {
            // This doesn't fully work bc in the vm we use provider.newContext, so they're accessing
            // separate contexts.
            // As a work around I added the preview bool to use the provider.viewContext instead.
            // For it to fully work, I somehow need to create the preview data on the same newContext used
            // in the vm
            EditDonationView(vm: .init(provider: previewProvider, donation: .preview(context: previewProvider.viewContext), preview: true))
        }
        .previewDisplayName("EditView With Data")
    }
}

extension EditDonationView {
	@ViewBuilder
	private func timeSection() -> some View {
		DatePicker("Date", selection: $vm.donationDay, in: ...Date(),displayedComponents: .date)
		DatePicker("Start Time", selection: $vm.donation.startTime, displayedComponents: .hourAndMinute)
		DatePicker("End Time", selection: $vm.donation.endTime, displayedComponents: .hourAndMinute)

		// Duration Row
		LabeledContent {
			Text(vm.donation.durationString)
		} label: {
			Text("Duration")
		}
	}

	@ViewBuilder
	private func infoSection() -> some View {
		proteinRow
		compensationRow
		amountDonatedRow
		cycleCountRow
	}

	private func notesSection() -> some View {
		TextField("Add notes here", text: $vm.donation.notes, axis: .vertical)
			.focused($focusedField, equals: .notes)
	}

	private var doneAction: some ToolbarContent {
		ToolbarItem(placement: .confirmationAction) {
			Button("Done") {
				do {
					try vm.save()
					dismiss()
				} catch EditDonationView.ViewModel.SaveError.notFilledIn {
					alertTitle = "Fill out all the info before saving"
					showingAlert = true
				} catch EditDonationView.ViewModel.SaveError.invalidDateRange {
					alertTitle = "Start Time must come before End Time"
					showingAlert = true
				} catch {
					print(error)
				}
			}
		}
	}

	private var cancelAction: some ToolbarContent {
		ToolbarItem(placement: .navigationBarLeading) {
			Button("Cancel", role: .cancel) { dismiss() }
		}
	}

	// MARK: - Info Section
	private var proteinRow: some View {
		DataField(
			text: $vm.proteinText,
			label: "Protein",
			placeholder: String(format: "%.1f", vm.donation.protein),
			color: .orange,
			suffix: "g/dL"
		)
		.keyboardType(.decimalPad)
		.focused($focusedField, equals: .protein)
		.onTapGesture { focusedField = .protein }
		.onChange(of: vm.proteinText) { text in
			guard Double(text) != nil else {
				vm.proteinText = ""
				return
			}
		}
	}

	private var compensationRow: some View {
		DataField(
			text: $vm.compensationText,
			label: "Compensation",
			placeholder: "\(vm.donation.compensation)",
			color: .green,
			prefix: "$"
		)
		.keyboardType(.numberPad)
		.focused($focusedField, equals: .compensation)
		.onTapGesture { focusedField = .compensation }
		.onChange(of: vm.compensationText) { text in
			guard Int16(text) != nil else {
				vm.compensationText = ""
				return
			}
		}
	}

	private var amountDonatedRow: some View {
		DataField(
			text: $vm.amountText,
			label: "Amount Donated",
			placeholder: "\(vm.donation.amountDonated)",
			color: .cyan,
			suffix: "mL"
		)
		.keyboardType(.numberPad)
		.focused($focusedField, equals: .donationAmount)
		.onTapGesture { focusedField = .donationAmount }
		.onChange(of: vm.amountText) { text in
			guard Int16(text) != nil else {
				vm.amountText = ""
				return
			}
		}
	}

	private var cycleCountRow: some View {
		DataField(
			text: $vm.cycleCountText,
			label: "Cycle Count",
			placeholder: "\(vm.donation.cycleCount)",
			color: .blue
		)
		.keyboardType(.numberPad)
		.focused($focusedField, equals: .cycle)
		.onTapGesture { focusedField = .cycle }
		.onChange(of: vm.cycleCountText) { text in
			guard Int16(text) != nil else {
				vm.cycleCountText = ""
				return
			}
		}
	}
}
