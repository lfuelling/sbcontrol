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
            Text("Current: \(deviceState.currentTemperature)°C")
                .bold()
                .font(.title)
            Text("Selected: \(deviceState.selectedTemperature)°C")
                .font(.title)
            HStack {
                Button {
                    let _ = deviceState.decreaseTemperature()
                } label: {
                    VStack {
                        Text("-")
                            .monospaced()
                            .font(.largeTitle)
                    }.padding(4)
                }.disabled(deviceState.selectedTemperature <= 57 || deviceState.writingValue)
                Spacer()
                Button {
                    let _ = deviceState.increaseTemperature()
                } label: {
                    VStack {
                        Text("+")
                            .monospaced()
                            .font(.largeTitle)
                    }.padding(4)
                }.disabled(deviceState.selectedTemperature >= 230 || deviceState.writingValue)
            }
        } header: {
            Text("Temperature")
        }
    }
}
