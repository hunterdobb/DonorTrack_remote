//
//  ContentView.swift
//  DonorTrack
//
//  Created by Hunter Dobbelmann on 1/13/23.
//

import SwiftUI

struct ContentView: View {
    var provider = DonationsProvider.shared
    
    var body: some View {
        TabView {
            NewDonationView(vm: .init(provider: provider))
                .tabItem {
                    Image(systemName: "plus.circle.fill")
                    Text("New Donation")
                }
            
            DonationsListView(vm: .init(provider: provider))
                .tabItem {
                    Image(systemName: "list.bullet.circle.fill")
                    Text("Donations")
                }
        }

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let preview = DonationsProvider.shared
        ContentView(provider: preview)
            .environment(\.managedObjectContext, preview.viewContext)
            .onAppear { DonationEntity.makePreview(count: 10, in: preview.viewContext) }
    }
}
