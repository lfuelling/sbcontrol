//
//  DeviceSettingsSection.swift
//  sbcontrol
//
//  Created by Lukas Fülling on 6/14/24.
//

import SwiftUI

struct DeviceSettingsSection: View {
    @EnvironmentObject private var deviceState: DeviceState
    
    @State private var deviceLEDBrightness: Double = -1 // TODO: debounce/throttle
    @State private var autoShutoffTime: Double = -1 // TODO: debounce/throttle
    
    var body: some View {
        if(deviceState.deviceDetermination.hasScreen ||
           deviceState.deviceDetermination.hasAutoshutoffTime) {
            Section {
                if(deviceState.deviceDetermination.hasScreen) {
                    VStack(alignment: .leading) {
                        Text("LED Brightness (\(Int(deviceLEDBrightness)))")
                        Slider(value: $deviceLEDBrightness, in: 1...100).onAppear {
                            deviceLEDBrightness = Double(deviceState.deviceLEDBrightness)
                        }.onChange(of: deviceLEDBrightness) {
                            if(Int(deviceLEDBrightness) != deviceState.deviceLEDBrightness) {
                                let _ = deviceState.setLEDBrightness(Int(deviceLEDBrightness))
                            }
                        }.onChange(of: deviceState.deviceLEDBrightness) {
                            deviceLEDBrightness = Double(deviceState.deviceLEDBrightness)
                        }
                    }.padding(.vertical, 4)
                }
                
                if(deviceState.deviceDetermination.hasAutoshutoffTime) {
                    VStack(alignment: .leading) {
                        Text("Auto-Shutoff Time (\(Int(autoShutoffTime / 60)) min)")
                        Slider(value: $autoShutoffTime, in: 1800...21600).onAppear {
                            autoShutoffTime = Double(deviceState.deviceAutoShutoffTime)
                        }.onChange(of: autoShutoffTime) {
                            if(Int(autoShutoffTime) != deviceState.deviceAutoShutoffTime) {
                                let _ = deviceState.setAutoShutoffTime(Int(autoShutoffTime))
                            }
                        }.onChange(of: deviceState.deviceAutoShutoffTime) {
                            autoShutoffTime = Double(deviceState.deviceAutoShutoffTime)
                        }
                    }.padding(.vertical, 4)
                }
            } header: {
                Text("Device Settings")
            }
        }
    }
}

#Preview {
    DeviceSettingsSection()
}
