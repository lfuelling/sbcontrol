//
//  DeviceControlsTemperatureSection.swift
//  sbcontrol
//
//  Created by Lukas Fülling on 6/11/24.
//

import SwiftUI

struct DeviceControlsTemperatureSection: View {
    @EnvironmentObject private var bleManager: BLEManager
    
    var body: some View {
        HStack {
            Button {
                bleManager.decreaseTemperature()
            } label: {
                VStack {
                    Text("-")
                        .monospaced()
                        .font(.largeTitle)
                }.padding(4)
            }.disabled(bleManager.selectedTemperature <= 57)
            VStack {
                Text("Current: \(bleManager.currentTemperature)°C")
                    .bold()
                    .font(.title)
                Text("Selected: \(bleManager.selectedTemperature)°C")
                    .font(.title)
            }.padding()
            Button {
                bleManager.increaseTemperature()
            } label: {
                VStack {
                    Text("+")
                        .monospaced()
                        .font(.largeTitle)
                }.padding(4)
            }.disabled(bleManager.selectedTemperature >= 230)
        }
    }
}

#Preview {
    DeviceControlsTemperatureSection()
}
