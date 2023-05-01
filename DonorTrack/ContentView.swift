//
//  ContentView.swift
//  DonorTrack
//
//  Created by Hunter Dobbelmann on 1/13/23.
//

import SwiftUI

struct ContentView: View {
    var provider = DataController.shared
    
    var body: some View {
        TabView {
			NewDonationView(vm: .init(provider: provider))
                .tabItem {
					Symbols.plusCircle
                    Text("New Donation")
                }
            
            DonationsListView(vm: .init(provider: provider))
                .tabItem {
					Symbols.listBullet
                    Text("Donations")
                }

			SettingsView()
				.tabItem {
					Symbols.gearShape
					Text("Settings")
				}
        }
        .dynamicTypeSize(.xSmall ... .xxxLarge)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let preview = DataController.shared
        ContentView(provider: preview)
            .environment(\.managedObjectContext, preview.viewContext)
            .onAppear { DonationEntity.makePreview(count: 10, in: preview.viewContext) }
    }
}
