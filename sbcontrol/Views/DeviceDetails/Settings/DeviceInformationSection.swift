//
//  DeviceInformationSection.swift
//  sbcontrol
//
//  Created by Lukas Fülling on 6/14/24.
//

import SwiftUI

struct DeviceInformationSection: View {
    @EnvironmentObject private var bleManager: BLEManager

    var body: some View {
        Section {
            HStack {
                Text("Operation Time")
                    .bold()
                Spacer()
                Text("\(bleManager.hoursOfOperation) hours")
            }
            HStack {
                Text("Serial Number")
                    .bold()
                Spacer()
                Text(bleManager.serialNumber)
                    .monospaced()
            }
            if(!bleManager.deviceFirmwareVersion.isEmpty) {
                HStack {
                    Text("Firmware Version")
                        .bold()
                    Spacer()
                    Text("\(bleManager.deviceFirmwareVersion)")
                }
            }
            if(!bleManager.deviceBLEFirmwareVersion.isEmpty) {
                HStack {
                    Text("BLE Firmware Version")
                        .bold()
                    Spacer()
                    Text("\(bleManager.deviceBLEFirmwareVersion)")
                }
            }
        } header: {
            Text("Device Information")
        }
    }
}

#Preview {
    DeviceInformationSection()
}
