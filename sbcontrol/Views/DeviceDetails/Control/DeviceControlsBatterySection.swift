//
//  DeviceControlsBatterySection.swift
//  sbcontrol
//
//  Created by Lukas Fülling on 6/14/24.
//

import SwiftUI

struct DeviceControlsBatterySection: View {
    @EnvironmentObject private var bleManager: BLEManager
    
    var body: some View {
        if(bleManager.deviceDetermination.hasBattery) {
            HStack {
                Text("\(bleManager.batteryPercent)%")
                
                if(bleManager.powerState) {
                    Image(systemName: "battery.100percent.bolt")
                        .foregroundColor(.green)
                } else if(bleManager.batteryPercent == -1) {
                    Image(systemName: "battery.0percent")
                        .foregroundColor(.secondary)
                } else if(bleManager.batteryPercent < 10) {
                    Image(systemName: "battery.0percent")
                        .foregroundColor(.red)
                } else if(bleManager.batteryPercent < 50) {
                    Image(systemName: "battery.25percent")
                } else if(bleManager.batteryPercent < 75) {
                    Image(systemName: "battery.50percent")
                } else if(bleManager.batteryPercent < 90) {
                    Image(systemName: "battery.75percent")
                } else {
                    Image(systemName: "battery.100percent")
                }
            }.font(.title)
        }
    }
}

#Preview {
    DeviceControlsBatterySection()
}
