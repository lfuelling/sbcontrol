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
                VStack {
                    Text("+")
                        .monospaced()
                        .font(.largeTitle)
                }.padding(4)
            }.disabled(deviceState.selectedTemperature >= 230 || deviceState.writingValue)
            Button {
                let _ = deviceState.decreaseTemperature()
            } label: {
                VStack {
                    Text("-")
                        .monospaced()
                        .font(.largeTitle)
                }.padding(4)
            }.disabled(deviceState.selectedTemperature <= 57 || deviceState.writingValue)
        } header: {
            Text("Temperature")
        }.toolbar {
            ToolbarItem(placement: .bottomBar, content: {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Current: \(deviceState.currentTemperature)°C")
                            .bold()
                            .font(.footnote)
                        Text("Selected: \(deviceState.selectedTemperature)°C")
                            .font(.footnote)
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Label {
                            Text("Heat \(deviceState.heatStatus ? "On" : "Off")")
                        } icon: {
                            Image(systemName: deviceState.heatStatus ? "thermometer.high" : "thermometer.medium.slash")
                        }.font(.footnote)
                        Label {
                            Text("Air \(deviceState.airStatus ? "On" : "Off")")
                        } icon: {
                            Image(systemName: deviceState.airStatus ? "humidifier.and.droplets.fill" : "humidifier.and.droplets")
                        }.font(.footnote)
                    }
                }
            })
        }
    }
}
