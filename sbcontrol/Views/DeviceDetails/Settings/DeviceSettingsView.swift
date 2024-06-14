//
//  DeviceSettingsView.swift
//  sbcontrol
//
//  Created by Lukas Fülling on 6/10/24.
//

import SwiftUI

struct DeviceSettingsView: View {
    @EnvironmentObject private var bleManager: BLEManager
    
    var body: some View {
        List {
            Section {
                Text("TODO!")
            } header: {
                Text("Device Settings")
            }
            
            Section {
                HStack {
                    Text("Operation Time")
                        .bold()
                    Spacer()
                    Text("\(bleManager.hoursOfOperation) hours")
                }
            } header: {
                Text("Device Information")
            }
        }.navigationTitle("Settings")
    }
}

#Preview {
    DeviceSettingsView()
}
