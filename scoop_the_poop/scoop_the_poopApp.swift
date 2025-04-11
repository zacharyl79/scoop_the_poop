//
//  scoop_the_poopApp.swift
//  scoop_the_poop
//
//  Created by Student on 4/11/25.
//

import SwiftUI

@main
struct scoop_the_poopApp: App {
    @StateObject private var handler: SQLiteHandler = SQLiteHandler()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(handler)
        }
    }
}
