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
        } header: {
            Text("Device Information")
        }
    }
}

#Preview {
    DeviceInformationSection()
}
