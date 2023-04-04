//
//  DonationsListView.swift
//  DonorTrack
//
//  Created by Hunter Dobbelmann on 1/13/23.
//

import StoreKit
import SwiftUI

struct DonationsListView: View {
	@ObservedObject var vm: ViewModel

	// Environment value to call as a function to trigger review dialog
	@Environment(\.requestReview) var requestReview: RequestReviewAction
	@EnvironmentObject private var reviewsManager: ReviewRequestManager

	// Must be in View, cannot go in vm
	@FetchRequest(fetchRequest: DonationEntity.all()) var donations

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
								} header: { totalHeader }
								.textCase(nil)
							}
							ForEach(vm.groupDonationsByMonth(donations), id: \.self) { (months: [DonationEntity]) in
								Section { // header below, shows month
									ForEach(months) { donation in
										// Workaround to hide default list indicator
										// I do this so I can move to upper right corner
										ZStack(alignment: .leading) {
											NavigationLink(value: donation) {
												EmptyView()
											}.opacity(0)

											DonationRowView(donation: donation,
															provider: vm.provider,
															showNotes: $vm.showNotes)
												.swipeActions(allowsFullSwipe: false) {
													deleteButton(donation: donation)
													editButton(donation: donation)
												}
										}
									}
								} header: { monthHeader(months: months) }
								.textCase(nil)
							} // ForEach
						} // List

						filterNotifier
					} // VStack
				}
			}
			.searchable(text: $vm.searchConfig.query, prompt: "Search Notes")
			.toolbar {
				ToolbarItem { optionsMenu }
			}
			.navigationDestination(for: DonationEntity.self) { donation in
				DonationDetailView(donation: donation, provider: vm.provider)
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
				EditDonationView(vm: .init(provider: vm.provider, donation: donation))
			}
			.onAppear {
				if reviewsManager.canAskForReview(donationCount: donations.count) {
					requestReview()
				}
			}
		}
	}
}

// MARK: - Preview
struct DonationsListView_Previews: PreviewProvider {
	static var previews: some View {
		let preview = DonationsProvider.shared
		DonationsListView(vm: .init(provider: .shared))
			.environment(\.managedObjectContext, preview.viewContext)
			.environmentObject(ReviewRequestManager())
			.previewDisplayName("List With Data")
			.onAppear { DonationEntity.makePreview(count: 10, in: preview.viewContext) }

		let emptyPreview = DonationsProvider.shared
		DonationsListView(vm: .init(provider: .shared))
			.environment(\.managedObjectContext, emptyPreview.viewContext)
			.environmentObject(ReviewRequestManager())
			.previewDisplayName("List With No Data")
	}
}

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
					Symbols.exclamationmarkCircle
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
			Text(vm.totalEarnedAllTime(donations))
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
				Symbols.exclamationmarkCircle
				Text("Filtered by Low Protein")
			}
			.padding(.bottom, 20)
			.foregroundColor(.orange)
			.font(.headline)
		}
	}

	private var optionsMenu: some View {
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
				vm.donationToEdit = .empty(context: DonationsProvider.shared.newContext)
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

	@ViewBuilder
	private func monthHeader(months: [DonationEntity]) -> some View {
		let isSameYear = Calendar.current.isDate(months[0].startTime, equalTo: .now, toGranularity: .year)
		let yearText = isSameYear ? "" : ", \(months[0].startTime.formatted(.dateTime.year()))"

		Text("\(months[0].startTime, format: .dateTime.month(.wide))\(yearText)")
			.foregroundColor(.secondary)
			.font(.headline)
			.bold()
	}

	private func deleteButton(donation: DonationEntity) -> some View {
		Button(role: .destructive) {
			do {
				// using provider.newContext is safer and prevents crashing
				try vm.provider.delete(donation, in: vm.provider.newContext)
			} catch {
				print(error)
			}
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
