//
//  DeviceDetailstemperatureSection.swift
//  sbcontrol
//
//  Created by Lukas Fülling on 9/26/24.
//  Copyright © 2024 Lerk Tech. All rights reserved.
//

import SwiftUI

struct DeviceDetailsTemperatureSection: View {
    @EnvironmentObject private var deviceState: DeviceState
    
    var body: some View {
        Section {
            Button {
                let _ = deviceState.increaseTemperature()
            } label: {
                Text("+")
                    .monospaced()
                    .font(.largeTitle)
            }.disabled(deviceState.selectedTemperature >= 230 || deviceState.writingValue)
            Button {
                let _ = deviceState.decreaseTemperature()
            } label: {
                Text("-")
                    .monospaced()
                    .font(.largeTitle)
            }.disabled(deviceState.selectedTemperature <= 57 || deviceState.writingValue)
        } header: {
            Text("Temperature")
        }
    }
}
