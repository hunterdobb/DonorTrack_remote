//
//  DonationsListView.swift
//  DonorTrack
//
//  Created by Hunter Dobbelmann on 1/13/23.
//

import StoreKit
import SwiftUI

// TODO: refactor this
struct WhiteGroupBoxStyle: GroupBoxStyle {
	func makeBody(configuration: Configuration) -> some View {
		VStack(spacing: 0) {
			configuration.label
				.font(.headline)
				.frame(maxWidth: .infinity, alignment: .leading)

			configuration.content
		}
		.padding(8)
		.background(Color("ListRowColor"),
					in: RoundedRectangle(cornerRadius: 8, style: .continuous))
	}
}

struct DonationsListView: View {
	@ObservedObject var vm: ViewModel

	@FetchRequest(fetchRequest: DonationEntity.all()) private var donations

	func groupByMonth(_ result: FetchedResults<DonationEntity>) -> [[DonationEntity]] {
		Dictionary(grouping: result) { (donation: DonationEntity) in
			donation.startTime.month
		}.values.sorted {
			if vm.sort == .newestFirst {
				return $0[0].startTime > $1[0].startTime
			} else {
				return $0[0].startTime < $1[0].startTime
			}
		}
	}

	func totalEarnedAllTime() -> String {
		let compensations = donations.map { Int($0.compensation) }
		let total = compensations.reduce(0, +)
		return "$\(total)"
	}

	// Environment value to call as a function to trigger review dialog
	@Environment(\.requestReview) var requestReview: RequestReviewAction
	@EnvironmentObject private var reviewsManager: ReviewRequestManager

	var body: some View {
		NavigationStack {
			ZStack {
				if donations.isEmpty && vm.searchConfig.query.isEmpty {
					emptyStateView
						.padding(.bottom, 100)
				} else if donations.isEmpty && !vm.searchConfig.query.isEmpty {
					Text("No Results")
						.frame(maxHeight: .infinity, alignment: .top)
						.padding(.top)
				} else {
					VStack {
						List {
							// TODO: Implement totals at top of list
							if vm.searchConfig.query.isEmpty && vm.searchConfig.filter == .all {
								Section {
									HStack {
										GroupBox {
											Text(totalEarnedAllTime())
												.font(.system(.title, design: .rounded, weight: .bold))
												.frame(maxWidth: .infinity, alignment: .leading)
												.padding(.top, 1)
										} label: {
											Text("Compensation")
												.foregroundStyle(.green)
										}
										.frame(maxWidth: .infinity)
										.groupBoxStyle(WhiteGroupBoxStyle())


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
									.listRowBackground(Color.clear)
									.listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
									.listRowSeparator(.hidden)
								} header: {
									Text("Totals")
										.foregroundColor(.secondary)
										.font(.headline)
										.bold()
								}
								.textCase(nil)
							}
							ForEach(groupByMonth(donations), id: \.self) { (months: [DonationEntity]) in
								Section { // header below, shows month
									ForEach(months) { donation in
										// Workaround to hide default list indicator
										// I do this so I can move to upper right corner
										ZStack(alignment: .leading){
											NavigationLink(value: donation) {
												EmptyView()

											}
											.opacity(0)

											DonationRowView(donation: donation, provider: vm.provider, showNotes: $vm.showNotes)

											//                                    .contextMenu {
											//                                        menuButtons
											//                                    }
												.swipeActions(allowsFullSwipe: false) {
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

													Button {
														vm.donationToEdit = donation
													} label: {
														Label("Edit", systemImage: "pencil")
													}
													.tint(.orange)
												}

										}
									}
								} header: {
									let isSameYear = Calendar.current.isDate(months[0].startTime, equalTo: .now, toGranularity: .year)
									let yearText = isSameYear ? "" : ", \(months[0].startTime.formatted(.dateTime.year()))"

									Text("\(months[0].startTime, format: .dateTime.month(.wide))\(yearText)")
										.foregroundColor(.secondary)
										.font(.headline)
										.bold()
								}
								.textCase(nil)
							}
						}
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
					//                    .background(.regularMaterial)

				}
			}
			.searchable(text: $vm.searchConfig.query, prompt: "Search Notes")
			.toolbar {
				ToolbarItem(placement: .automatic) {
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
				// onDismiss
				vm.donationToEdit = nil
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

	private var totalEarnedView: some View {
		Text(totalEarnedAllTime())
			.font(.system(.title, design: .rounded, weight: .bold))
			.foregroundColor(.green)
			.padding()
			.listRowBackground(Color.clear)
			.listRowSeparator(.hidden)
			.background {
				RoundedRectangle(cornerRadius: 10)
					.foregroundColor(.white)
			}
			.offset(x: -15, y: 10)
	}

	private var menuButtons: some View {
		Group {
			Button(role: .destructive) {

			} label: {
				Label("Delete", systemImage: "trash")
			}

			Button() {
				print("Enable geolocation")
			} label: {
				Label("Edit", systemImage: "pencil")
			}
			.tint(.orange)
		}
	}
}
