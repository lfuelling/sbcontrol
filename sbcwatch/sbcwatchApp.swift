//
//  sbcwatchApp.swift
//  sbcwatch Watch App
//
//  Created by Lukas Fülling on 9/26/24.
//

import SwiftUI

@main
struct sbcwatch_Watch_AppApp: App {
    
    @StateObject var bleManager = BLEManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(bleManager)
        }
    }
}
