//
//  StealthBrowserApp.swift
//  StealthBrowser
//
//  Created by robin on 6/21/26.
//

import SwiftUI
import CoreData

@main
struct StealthBrowserApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
