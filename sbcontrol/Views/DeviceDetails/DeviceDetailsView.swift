//
//  DeviceDetailsView.swift
//  sbcontrol
//
//  Created by Lukas Fülling on 6/9/24.
//

import SwiftUI

struct DeviceDetailsView: View {
    @EnvironmentObject private var bleManager: BLEManager

    var body: some View {
        VStack {
            if(bleManager.connected) {
                Text(bleManager.peripheral.name ??  "Unnamed")
                    .font(.largeTitle)
                Spacer()
                Text("Current: \(bleManager.currentTemperature)°C")
                    .bold()
                    .font(.title)
                Text("Selected: \(bleManager.selectedTemperature)°C")
                    .font(.title)
                HStack {
                    Spacer()
                    Image(systemName: bleManager.heatStatue ? "thermometer.high" : "thermometer.medium.slash")
                        .resizable()
                        .frame(width: 32, height: 32)
                    Spacer()
                    Image(systemName: bleManager.airStatue ? "humidifier.and.droplets.fill" : "humidifier.and.droplets")
                        .resizable()
                        .frame(width: 32, height: 32)
                        .onTapGesture {
                            bleManager.toggleAirPump()
                        }
                    Spacer()
                }
                Spacer()
            } else {
                ProgressView().progressViewStyle(.circular)
            }
        }.navigationTitle("Device Control")
    }
}

#Preview {
    DeviceDetailsView()
}
