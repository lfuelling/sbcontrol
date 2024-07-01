//
//  DeviceControlsTemperatureSection.swift
//  sbcontrol
//
//  Created by Lukas Fülling on 6/11/24.
//

import SwiftUI

struct DeviceControlsTemperatureSection: View {
    @EnvironmentObject private var deviceState: DeviceState
    
    var body: some View {
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
            VStack {
                Text("Current: \(deviceState.currentTemperature)°C")
                    .bold()
                    .font(.title)
                HStack(spacing: 0) {
                    Text("Selected: ")
                        .font(.title)
                    SelectedTemperatureIndicator()
                }
            }.padding()
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
    }
}

#Preview {
    DeviceControlsTemperatureSection()
}
