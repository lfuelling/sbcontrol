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
            VStack {
                Text("Current: \(deviceState.currentTemperature)°C")
                    .bold()
                    .font(.title)
                HStack(spacing: 0) {
                    Text("Selected: ")
                        .font(.title)
                    VStack {
                        Text("\(deviceState.selectedTemperature)°C")
                            .font(.title)
                    }
                }
            }.padding()
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
