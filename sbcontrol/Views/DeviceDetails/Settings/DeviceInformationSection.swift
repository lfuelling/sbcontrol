//
//  DeviceInformationSection.swift
//  sbcontrol
//
//  Created by Lukas Fülling on 6/14/24.
//

import SwiftUI

struct DeviceInformationSection: View {
    @EnvironmentObject private var deviceState: DeviceState
    
    var body: some View {
        Section {
            HStack {
                Text("Operation Time")
                    .bold()
                Spacer()
                Text("\(deviceState.hoursOfOperation) hours")
            }
#if os(macOS)
            .padding(.vertical, 4)
#endif
            HStack {
                Text("Serial Number")
                    .bold()
                Spacer()
                Text(deviceState.serialNumber)
                    .monospaced()
            }
#if os(macOS)
            .padding(.vertical, 4)
#endif
            if(!deviceState.deviceFirmwareVersion.isEmpty) {
                HStack {
                    Text("Firmware Version")
                        .bold()
                    Spacer()
                    Text("\(deviceState.deviceFirmwareVersion)")
                }
#if os(macOS)
                .padding(.vertical, 4)
#endif
            }
            if(!deviceState.deviceBLEFirmwareVersion.isEmpty) {
                HStack {
                    Text("BLE Firmware Version")
                        .bold()
                    Spacer()
                    Text("\(deviceState.deviceBLEFirmwareVersion)")
                }
#if os(macOS)
                .padding(.vertical, 4)
#endif
            }
        } header: {
            Text("Device Information")
        }
    }
}

#Preview {
    DeviceInformationSection()
}
