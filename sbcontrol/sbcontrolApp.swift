//
//  sbcontrolApp.swift
//  sbcontrol
//
//  Created by Lukas Fülling on 6/8/24.
//

import SwiftUI

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
