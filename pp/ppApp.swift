//
//  ppApp.swift
//  pp
//
//  Created by Apple Esprit on 21/11/2024.
//	

import SwiftUI

@main
struct ppApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            LoginView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
