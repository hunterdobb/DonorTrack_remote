//
//  DonationsListView.swift
//  DonorTrack
//
//  Created by Hunter Dobbelmann on 1/13/23.
//

import StoreKit
import SwiftUI

struct DonationsListView: View {
	//	@ObservedObject var vm: ViewModel
	@StateObject var vm: ViewModel
	@EnvironmentObject var dataController: DataController
	@State private var showEditNewDonation = false

	// Environment value to call as a function to trigger review dialog
	@Environment(\.requestReview) var requestReview: RequestReviewAction
	@EnvironmentObject private var reviewsManager: ReviewRequestManager

	@FetchRequest(fetchRequest: DonationEntity.all()) var donations

	//	@SectionedFetchRequest<String, DonationEntity>(
	//		sectionIdentifier: \DonationEntity.monthString,
	//		sortDescriptors: [SortDescriptor(\.monthString, order: .reverse)]
	//	)
	//	private var sectionDonations: SectionedFetchResults<String, DonationEntity>

	// TODO: refactor this
	let currencyFormatter: NumberFormatter = {
		let formatter = NumberFormatter()
		formatter.numberStyle = .currency
		formatter.maximumFractionDigits = 0
		formatter.currencySymbol = Locale.current.currencySymbol ?? ""
		return formatter
	}()

	init(dataController: DataController) {
		let viewModel = ViewModel(dataController: dataController)
		_vm = StateObject(wrappedValue: viewModel)
	}

	var body: some View {
		NavigationStack {
			ZStack {
				if donations.isEmpty && vm.searchConfig.query.isEmpty {
					emptyStateView.padding(.bottom, 100)
				} else if donations.isEmpty && !vm.searchConfig.query.isEmpty {
					Text("No Results")
						.frame(maxHeight: .infinity, alignment: .top)
						.padding(.top)
				} else {
					VStack {
						List {
							if vm.searchConfig.query.isEmpty && vm.searchConfig.filter == .all {
								Section {
									HStack {
										totalCompensation
										totalDonations
									}
									.listRowBackground(Color.clear)
									.listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
									.listRowSeparator(.hidden)
								} header: {
									totalHeader
								}
								.textCase(nil)
							}

							ForEach(vm.groupDonationsByMonth(donations), id: \.self) { (months: [DonationEntity]) in
								Section { // header below, shows month
									ForEach(months) { donation in
										NavigationLink(value: donation) {
											DonationRowView(
												donation: donation,
												dataController: dataController,
												showNotes: $vm.showNotes
											)
											.swipeActions(allowsFullSwipe: false) {
												deleteButton(donation: donation)
												editButton(donation: donation)
											}
										}
									}
								} header: {
									monthHeader(months: months)
								}
								.textCase(nil)
							}
						}
					}
					filterNotifier
				}
			}
			.searchable(text: $vm.searchConfig.query, prompt: "Search Notes")
			.toolbar(content: optionsMenu)
			.navigationDestination(for: DonationEntity.self) { donation in
				DonationDetailView(donation: donation)
			}
			.onChange(of: vm.searchConfig) { newConfig in
				donations.nsPredicate = DonationEntity.filter(with: newConfig)

				if vm.searchConfig.query.isEmpty {
					vm.showNotes = false
				} else {
					vm.showNotes = true
				}
			}
			.onChange(of: vm.sort) { newSort in
				donations.nsSortDescriptors = DonationEntity.sort(order: newSort)
			}
			.navigationTitle("Donations")
			.sheet(item: $vm.donationToEdit) {
				vm.donationToEdit = nil // onDismiss
			} content: { donation in
				EditDonationView(dataController: dataController, donation: donation)
	//			EditDonationView(vm: .init(provider: vm.dataController, donation: donation))
			}
			.onAppear {
				if reviewsManager.canAskForReview(donationCount: donations.count) {
					requestReview()
				}
			}
			.sheet(isPresented: $showEditNewDonation) {
				EditDonationView(dataController: dataController)
			}
		}
	}
}


// MARK: - Preview
#Preview("List With Data") {
	//	let preview = DataController.shared
	return DonationsListView(dataController: .preview)
		.environmentObject(DataController.preview)
		.environmentObject(ReviewRequestManager())
	//		.environment(\.managedObjectContext, preview.viewContext)

	//		.onAppear { DonationEntity.makePreview(count: 10, in: preview.viewContext) }

	//	let preview = DataController.shared
	//	return DonationsListView(vm: .init(dataController: .preview))
	//		.environment(\.managedObjectContext, preview.viewContext)
	//		.environmentObject(ReviewRequestManager())
	//		.onAppear { DonationEntity.makePreview(count: 10, in: preview.viewContext) }
}

//#Preview("List With No Data") {
//	let emptyPreview = DataController.shared
//	return DonationsListView(vm: .init(dataController: .emptyPreview))
//		.environment(\.managedObjectContext, emptyPreview.viewContext)
//		.environmentObject(ReviewRequestManager())
//}

// MARK: - Views
extension DonationsListView {
	private var emptyStateView: some View {
		VStack(spacing: 15) {
			Text("No Donations")
				.frame(maxWidth: .infinity, alignment: .leading)
				.font(.largeTitle.bold())
			Text("Track your donations using the 'New Donation' tab.")
				.frame(maxWidth: .infinity, alignment: .leading)
				.font(.body)

			Text("You can also add donations manually by tapping the button above and selecting 'Add Donation Manually'")
				.frame(maxWidth: .infinity, alignment: .leading)
				.font(.callout)
				.foregroundColor(.primary.opacity(0.6))

			if vm.searchConfig.filter == .lowProtein {
				Divider()
				HStack {
					Symbols.exclamationMarkCircle
					Text("Filtered by Low Protein")
				}
				.foregroundColor(.orange)
				.font(.headline)
			}
		}
		.padding()
		.background(.ultraThickMaterial, in: RoundedRectangle(cornerRadius: 10))
		.padding()
	}

	private var totalHeader: some View {
		Text("Totals")
			.foregroundColor(.secondary)
			.font(.headline)
			.bold()
	}

	private var totalCompensation: some View {
		GroupBox {
			Text(currencyFormatter.string(from: NSNumber(value: vm.totalEarnedAllTime(donations))) ?? "")
				.font(.system(.title, design: .rounded, weight: .bold))
				.frame(maxWidth: .infinity, alignment: .leading)
				.padding(.top, 1)

		} label: {
			Text("Compensation")
				.foregroundStyle(.green)
		}
		.frame(maxWidth: .infinity)
		.groupBoxStyle(WhiteGroupBoxStyle())
	}

	private var totalDonations: some View {
		GroupBox {
			Text("\(donations.count)")
				.font(.system(.title, design: .rounded, weight: .bold))

				.frame(maxWidth: .infinity, alignment: .leading)
				.padding(.top, 1)
		} label: {
			Text("Donations")
				.foregroundStyle(.orange)
		}
		.frame(maxWidth: .infinity)
		.groupBoxStyle(WhiteGroupBoxStyle())
	}

	@ViewBuilder
	private var filterNotifier: some View {
		if vm.searchConfig.filter == .lowProtein {
			HStack {
				Symbols.exclamationMarkCircle
				Text("Filtered by Low Protein")
			}
			.padding(.bottom, 20)
			.foregroundColor(.orange)
			.font(.headline)
		}
	}

	@ToolbarContentBuilder
	private func optionsMenu() -> some ToolbarContent {
		ToolbarItem(placement: .primaryAction) {
			Menu {
				Picker("Sort", selection: $vm.sort) {
					Text("Newest First").tag(Sort.newestFirst)
					Text("Oldest First").tag(Sort.oldestFirst)
				}

				Picker("Filter Donations", selection: $vm.searchConfig.filter) {
					Label("Show All", systemImage: "list.bullet")
						.tag(SearchConfig.Filter.all)

					Label("Show Low Protein", systemImage: "drop.triangle")
						.tag(SearchConfig.Filter.lowProtein)
				}

				Button {
					showEditNewDonation = true
				} label: {
					Label("Add Donation Manually", systemImage: "keyboard")
				}
			} label: {
				Label("Options", systemImage: vm.searchConfig.filter == .lowProtein ?
					  "ellipsis.circle.fill" : "ellipsis.circle")
				.foregroundColor(vm.searchConfig.filter == .lowProtein ? .orange : .blue)
				.font(.title3)
			}
		}

		ToolbarItem {
#if DEBUG
			Button {
				dataController.deleteAll()
				dataController.createSampleData(count: 50)
			} label: {
				Label("ADD SAMPLES", systemImage: "flame")
			}
#endif
		}
	}

	@ViewBuilder
	private func monthHeader(months: [DonationEntity]) -> some View {
		let isSameYear = Calendar.current.isDate(months[0].donationStartTime, equalTo: .now, toGranularity: .year)
		let yearText = isSameYear ? "" : ", \(months[0].donationStartTime.formatted(.dateTime.year()))"

		Text("\(months[0].donationStartTime, format: .dateTime.month(.wide))\(yearText)")
			.foregroundColor(.secondary)
			.font(.headline)
			.bold()
	}

	private func deleteButton(donation: DonationEntity) -> some View {
		Button(role: .destructive) {
			vm.dataController.delete(donation)
		} label: {
			Label("Delete", systemImage: "trash")
		}
	}

	private func editButton(donation: DonationEntity) -> some View {
		Button {
			vm.donationToEdit = donation
		} label: {
			Label("Edit", systemImage: "pencil")
		}
		.tint(.orange)
	}
}

