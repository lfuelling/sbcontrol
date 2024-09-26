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
            DeviceSettingsSection()
            DeviceInformationSection()
        }.navigationTitle("Settings")
    }
}

#Preview {
    DeviceSettingsView()
}
