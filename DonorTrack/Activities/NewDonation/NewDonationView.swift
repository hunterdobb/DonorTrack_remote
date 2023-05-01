//
//  NewDonationView.swift
//  DonorTrack
//
//  Created by Hunter Dobbelmann on 1/13/23.
//

import Combine
import SwiftUI

/*
 init(dataController: DataController) {
	let viewModel = ViewModel(dataController: dataController)
	_viewModel = StateObject(wrappedValue: viewModel)
 }
 */

struct NewDonationView: View {
    @ObservedObject var vm: ViewModel

    @FocusState private var focusedField: FocusedField?
    @State private var tmp = Date()
	@State private var shouldShowSuccess = false
    
    enum FocusedField {
        case donationAmount, protein, compensation, notes
    }

    var body: some View {
        NavigationStack {
            ScrollViewReader { value in
                ScrollView {
                    VStack(alignment: .leading) {
//						if vm.donationState == .idle {
//							startDonationTip.padding(.bottom)
//						} else {
//							donatingNowInfo.padding(.bottom)
//						}

						donatingNowInfo
							.padding(.bottom, 8)
							.padding(.top, -8)
                        valueFields

						if vm.donationState != .idle {
							cycleCountView
						}

						notesField.padding(.top)

                        if focusedField == nil { scrollSpacer }
                    }
					.onChange(of: vm.isSaved) { isSaved in
						if isSaved {
							withAnimation(.spring()) {
								shouldShowSuccess.toggle()
								hapticNotification(.success)
							}

						}
					}
					.onAppear {
						// This fixes a bug where the check mark after saving would stay on the
						// screen if the user quickly changed tabs.
						shouldShowSuccess = false
					}
					.overlay {
						if shouldShowSuccess {
							CheckmarkView()
								.transition(.scale.combined(with: .opacity))
								.onAppear {
									DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
										withAnimation(.spring()) {
											shouldShowSuccess.toggle()
											vm.isSaved = false
										}
									}
								}
						}
					}
                    .onReceive(vm.$donationState) { state in
                        // This is a temporary fix to make the timer start updating
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            if state == .started {
                                tmp = .now
                            }
                        }
                    }
                    .id("top")
                    .padding()
                    .onChange(of: focusedField) { _ in
                        if focusedField == .notes {
                            withAnimation {
                                value.scrollTo("notes", anchor: .center)
                            }
                        }

                        if focusedField == nil {
                            withAnimation {
                                value.scrollTo("top", anchor: .top)
                            }
                        }
                    }
                    .onChange(of: vm.donation.notes) { _ in
                        withAnimation {
                            value.scrollTo("notes", anchor: .bottom)
                        }
                    }
                }
            }
            .overlay(alignment: .bottom) {
                if focusedField == nil {
                    actionButton
                }
            }
            .navigationTitle("New Donation")
//            .navigationBarTitleDisplayMode(.inline)
            .scrollDismissesKeyboard(.automatic)
            .alert(vm.alertTitle, isPresented: $vm.showingNotFilledInAlert) { }
            .alert(vm.alertTitle, isPresented: $vm.showingFinishConfirmationAlert) {
                Button("Finish") {
                    vm.finishDonation()
                }

                Button("Cancel", role: .cancel) {}
            }
            .alert(vm.alertTitle, isPresented: $vm.showingResetConfirmationAlert) {
                Button("Reset", role: .destructive) {
                    vm.resetView()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text(vm.alertMessage)
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    keyboardToolbarButtons
                }

                ToolbarItem(placement: .destructiveAction) {
                    if vm.donationState > .idle {
                        Button("Reset") {
                            vm.alertTitle = "Are you sure?"
                            vm.alertMessage = "This will delete all the current info and cannot be undone."
                            vm.showingResetConfirmationAlert = true
                        }
                    }
                }
            }
        }
    }
}


struct NewDonationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            let preview = DataController.shared
			NewDonationView(vm: .init(provider: preview))
                .environment(\.managedObjectContext, preview.viewContext)
        }
    }
}

// MARK: - Views Extension
extension NewDonationView {
    private var valueFields: some View {
        VStack(alignment: .leading) {
            Text("Enter Donation Info")
				.padding(.bottom, -2)
				.padding(.leading, 8)
				.foregroundColor(.secondary)
                .font(.headline)

            ValueField(text: $vm.amountText, label: "Donation Amount", placeholder: "0", suffix: "mL", color: .cyan)
                .keyboardType(.numberPad)
                .focused($focusedField, equals: .donationAmount)
                .onTapGesture {
                    focusedField = .donationAmount
                    print("\(String(describing: focusedField))")
                }
                .onChange(of: vm.amountText) { text in
                    guard let amountDonated = Int16(text) else {
                        vm.amountText = ""
                        return
                    }
                    vm.donation.amountDonated = amountDonated
                }

                HStack {
                    ValueField(text: $vm.proteinText, label: "Protein", placeholder: "0.0", suffix: "g/dL", color: .orange)
                        .keyboardType(.decimalPad)
                        .focused($focusedField, equals: .protein)
                        .onChange(of: vm.proteinText) { text in
                            guard let protein = Double(text) else {
                                vm.proteinText = ""
                                return
                            }
                            vm.donation.protein = protein
                        }

                    ValueField(text: $vm.compensationText, label: "Compensation", placeholder: "0", prefix: "$", color: .green)
                        .keyboardType(.numberPad)
                        .focused($focusedField, equals: .compensation)
                        .onChange(of: vm.compensationText) { text in
                            guard let compensation = Int16(text) else {
                                vm.compensationText = ""
                                return
                            }
                            vm.donation.compensation = compensation
                        }
                }
        }
    }

    private var notesField: some View {
        VStack {
            Text("Notes")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            TextField("Add notes here", text: $vm.donation.notes, axis: .vertical)
                .padding(.bottom, 5)
                .focused($focusedField, equals: .notes)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 15))
        .padding(.bottom)
        .id("notes")
    }

    private var startDonationTip: some View {
        Text("Tap Start Donation below when your donation begins")
            .foregroundColor(.secondary)
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 10))
    }

    private var cycleCountView: some View {
        HStack {
            Text("Cycles: \(vm.cycleCount)")
                .font(.headline)

            Spacer()

            // undo cycle
            Button {
                vm.undoCycleCount()
            } label: {
				Symbols.arrowUTurn
                    .frame(width: 50, height: 35)
                    .font(.largeTitle)
                    .bold()
            }
            .allowsHitTesting(vm.canUndoCycleCount)
            .opacity(vm.canUndoCycleCount ? 1 : 0.3)
            .buttonStyle(.bordered)
            .tint(.orange)
            .buttonBorderShape(.capsule)

            // increment cycle
            Button {
                vm.incrementCycleCount()
            } label: {
				Symbols.plus
                    .frame(width: 100, height: 35)
                    .font(.largeTitle)
                    .bold()
            }
            .buttonStyle(.bordered)
            .tint(.blue)
            .buttonBorderShape(.capsule)

        }
        .padding([.top, .bottom, .trailing], 10)
        .padding(.leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 10))
        .animation(.default, value: vm.donationState)
    }

    private var donatingNowInfo: some View {
        VStack(alignment: .leading) {
			if vm.donationState != .finished {
				HStack {
					Text("Start Time")
					Spacer()
					if vm.donationState == .started {
						Text(vm.donation.startTime, style: .time)
							.foregroundColor(.secondary)
					} else {
						Text("Not Started")
							.foregroundColor(.secondary)
					}

				}
			}

			if vm.donationState == .finished {
                HStack {
                    Text("Time")
                    Spacer()
					HStack {
						Text(vm.donation.startTime, style: .time)
						Text("-")
						Text(vm.donation.endTime, style: .time)
					}
					.foregroundColor(.secondary)
                }
            }

			Divider()

			donationDuration.padding(.top, 5)
        }
        .font(.headline)
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 15))
    }

	@ViewBuilder
	private var donationDuration: some View {
		if let startTime = vm.startTime {
			HStack {
				Text("Duration").font(.headline)
				Spacer()
				if vm.donationState == .started {
					Text(startTime, style: .timer)
						.monospacedDigit()
						.bold()
						.foregroundColor(.secondary)
				} else {
					if vm.endTime != nil {
						Text(vm.donation.durationString)
							.font(.headline)
							.foregroundColor(.secondary)
					}
				}

			}
		} else {
			HStack {
				Text("Duration").font(.headline)
				Spacer()
				Text("-:--")
					.foregroundColor(.secondary)
			}
		}
	}

    private var actionButton: some View {
        Button {
            vm.actionButtonTapped()
        } label: {
            // This button will switch between Start, Finish, and Save
            Text(vm.actionButtonText)
                .frame(maxWidth: .infinity)

        }
        .font(.system(.largeTitle, design: .rounded))
        .bold()
        .foregroundColor(vm.actionButtonColor)
        .padding(.vertical)
        .background(vm.actionButtonColor.opacity(0.2))
        .background(.ultraThinMaterial, in: Capsule())
        .padding(.horizontal, 10)
        .padding(.bottom, 8)
    }

    private var keyboardToolbarButtons: some View {
        HStack {
            // Temporary
            Button {
                focusedField = nil
            } label: {
				Symbols.dismissKeyboard
            }
            .font(.headline)
            .frame(maxWidth: .infinity)

            // TODO: V1.1 keyBoardToolbarButtons
            //            Button {
            //
            //            } label: {
            //                Text("Done")
            //                    .padding(.horizontal, 16)
            //            }
            //            .font(.headline)
            //            .tint(.blue)
            //            .buttonStyle(.bordered)
            //
            //            Spacer()
            //
            //            HStack {
            //                Button {
            //                    print("Clicked")
            //                } label: {
            //                    Text("Previous")
            //                }
            //
            //                Button {
            //                    print("Clicked")
            //                } label: {
            //                    Text("Next")
            //                        .padding(.horizontal, 16)
            //                }
            //            }
            //            .font(.headline)
            //            .buttonStyle(.bordered)
            //            .tint(.blue)
        }
    }

    private var scrollSpacer: some View {
        Text("Scroll Spacer")
            .font(.system(.largeTitle, design: .rounded))
        //            .padding(.vertical)
            .hidden()
    }
}

