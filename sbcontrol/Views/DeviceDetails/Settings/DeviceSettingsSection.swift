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
    @State private var autoShutoffTime: Double = -1
    
    var body: some View {
        Section {
            if(bleManager.deviceDetermination.hasScreen) {
                VStack(alignment: .leading) {
                    Text("LED Brightness (\(Int(deviceLEDBrightness)))")
                    Slider(value: $deviceLEDBrightness, in: 1...100).onAppear {
                        deviceLEDBrightness = Double(bleManager.deviceLEDBrightness)
                    }.onChange(of: deviceLEDBrightness) {
                        if(Int(deviceLEDBrightness) != bleManager.deviceLEDBrightness) {
                            let _ = bleManager.setLEDBrightness(Int(deviceLEDBrightness))
                        }
                    }.onChange(of: bleManager.deviceLEDBrightness) {
                        deviceLEDBrightness = Double(bleManager.deviceLEDBrightness)
                    }
                }.padding(.vertical, 4)
            }
            
            if(bleManager.deviceDetermination.hasAutoshutoffTime) {
                VStack(alignment: .leading) {
                    Text("Auto-Shutoff Time (\(Int(autoShutoffTime / 60)) min)")
                    Slider(value: $autoShutoffTime, in: 1800...21600).onAppear {
                        autoShutoffTime = Double(bleManager.deviceAutoShutoffTime)
                    }.onChange(of: autoShutoffTime) {
                        if(Int(autoShutoffTime) != bleManager.deviceAutoShutoffTime) {
                            let _ = bleManager.setAutoShutoffTime(Int(autoShutoffTime))
                        }
                    }.onChange(of: bleManager.deviceAutoShutoffTime) {
                        autoShutoffTime = Double(bleManager.deviceAutoShutoffTime)
                    }
                }.padding(.vertical, 4)
            }
        } header: {
            Text("Device Settings")
        }
    }
}

#Preview {
    DeviceSettingsSection()
}
