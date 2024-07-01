//
//  DeviceSettingsSection.swift
//  sbcontrol
//
//  Created by Lukas Fülling on 6/14/24.
//

import SwiftUI

struct DeviceSettingsSection: View {
    @EnvironmentObject private var bleManager: BLEManager
    
    @State private var deviceLEDBrightness: Double = -1
    
    var body: some View {
        Section {
            if(bleManager.deviceDetermination.hasScreen) {
                Slider(value: $deviceLEDBrightness, in: 1...100, label: {
                    Text("LED Brightness")
                }).onAppear {
                    deviceLEDBrightness = Double(bleManager.deviceLEDBrightness)
                }.onChange(of: deviceLEDBrightness) {
                    if(Int(deviceLEDBrightness) != bleManager.deviceLEDBrightness) {
                        let _ = bleManager.setLEDBrightness(Int(deviceLEDBrightness))
                    }
                }.onChange(of: bleManager.deviceLEDBrightness) {
                    deviceLEDBrightness = Double(bleManager.deviceLEDBrightness)
                }
            }
        } header: {
            Text("Device Settings")
        }
    }
}

#Preview {
    DeviceSettingsSection()
}
