//
//  sbcontrolApp.swift
//  sbcontrol
//
//  Created by Lukas Fülling on 6/8/24.
//

import SwiftUI

#if os(macOS)
@main
struct sbcontrolApp: App {
    @NSApplicationDelegateAdaptor private var appDelegate: AppDelegate
    
    @StateObject var bleManager = BLEManager()
    
    var body: some Scene {
        Window("SBControl", id: "main") {
            ContentView()
                .environmentObject(bleManager)
        }.commands {
            SidebarCommands()
        }
        Settings {
            SettingsView()
        }
    }
}
#else
@main
struct sbcontrolApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var bleManager = BLEManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(bleManager)
        }
    }
}
#endif
