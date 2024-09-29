//
//  DeviceControlsBatterySection.swift
//  sbcontrol
//
//  Created by Lukas Fülling on 6/14/24.
//

import SwiftUI

struct DeviceControlsBatterySection: View {
    @EnvironmentObject private var deviceState: DeviceState
    
    var body: some View {
        if(deviceState.deviceDetermination.hasBattery) {
            HStack {
                Text("\(deviceState.batteryPercent)%")
                
                if(deviceState.powerState) {
                    Image(systemName: "battery.100percent.bolt")
                        .foregroundColor(.green)
                } else if(deviceState.batteryPercent == -1) {
                    Image(systemName: "battery.0percent")
                        .foregroundColor(.secondary)
                } else if(deviceState.batteryPercent < 10) {
                    Image(systemName: "battery.0percent")
                        .foregroundColor(.red)
                } else if(deviceState.batteryPercent < 50) {
                    Image(systemName: "battery.25percent")
                } else if(deviceState.batteryPercent < 75) {
                    Image(systemName: "battery.50percent")
                } else if(deviceState.batteryPercent < 90) {
                    Image(systemName: "battery.75percent")
                } else {
                    Image(systemName: "battery.100percent")
                }
            }
        }
    }
}

#Preview {
    DeviceControlsBatterySection()
}
