//
//  DonationsListView.swift
//  DonorTrack
//
//  Created by Hunter Dobbelmann on 1/13/23.
//

import SwiftUI

struct DonationsListView: View {
    @ObservedObject var vm: ViewModel

    @FetchRequest(fetchRequest: DonationEntity.all()) private var donations

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
                    List {
                        ForEach(donations) { donation in
                            // Workaround to hide default list indicator
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
                    }
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
                }
            }
            .searchable(text: $vm.searchConfig.query, prompt: "Search Notes")
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

        }
    }
}

struct DonationsListView_Previews: PreviewProvider {
    static var previews: some View {
        let preview = DonationsProvider.shared

        DonationsListView(vm: .init(provider: .shared))
            .environment(\.managedObjectContext, preview.viewContext)
            .previewDisplayName("List With Data")
            .onAppear { DonationEntity.makePreview(count: 10, in: preview.viewContext) }

        let emptyPreview = DonationsProvider.shared
        DonationsListView(vm: .init(provider: .shared))
            .environment(\.managedObjectContext, emptyPreview.viewContext)
            .previewDisplayName("List With No Data")
    }
}

extension DonationsListView {
    private var emptyStateView: some View {
        VStack(spacing: 15) {
            Text("No Donations")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.largeTitle.bold())
            Text("Start tracking your first donation by using the 'New' tab below.")
                .font(.callout)
        }
        .padding()
        .background(.ultraThickMaterial, in: RoundedRectangle(cornerRadius: 10))
        .padding()
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
