//
//  InfoTabView.swift
//  sbcontrol
//
//  Created by Lukas Fülling on 28.09.24.
//  Copyright © 2024 Lerk Tech. All rights reserved.
//

import SwiftUI

struct DeviceInfoView: View {
    
    @EnvironmentObject private var bleManager: BLEManager
    @EnvironmentObject private var deviceState: DeviceState
    
    var body: some View {
        List {
            Section {
                HStack {
                    Text("Operation Time")
                        .bold()
                    Spacer()
                    Text("\(deviceState.hoursOfOperation) hours")
                }
                HStack {
                    Text("Serial Number")
                        .bold()
                    Spacer()
                    Text(deviceState.serialNumber)
                        .monospaced()
                }
                if(!deviceState.deviceFirmwareVersion.isEmpty) {
                    HStack {
                        Text("Firmware Version")
                            .bold()
                        Spacer()
                        Text("\(deviceState.deviceFirmwareVersion)")
                    }
                }
                if(!deviceState.deviceBLEFirmwareVersion.isEmpty) {
                    HStack {
                        Text("BLE Firmware Version")
                            .bold()
                        Spacer()
                        Text("\(deviceState.deviceBLEFirmwareVersion)")
                    }
                }
            } header: {
                Text("Device Information")
            }
            
            Section {
                Button {
                    bleManager.disconnect(peripheral: deviceState.peripheral)
                } label: {
                    Label {
                        Text("Disconnect")
                    } icon: {
                        Image(systemName: "door.left.hand.open")
                    }
                }
            } header: {
                Text("Disconnect")
            }
        }.navigationTitle("Info")
    }
}
