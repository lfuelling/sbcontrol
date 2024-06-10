//
//  DeviceDetailsHeaderView.swift
//  sbcontrol
//
//  Created by Lukas Fülling on 6/10/24.
//

import SwiftUI

struct DeviceDetailsHeaderView: View {
    @EnvironmentObject private var bleManager: BLEManager
    
    var body: some View {
        HStack {
            Spacer()
            VStack {
                Image(systemName: bleManager.heatStatus ? "thermometer.high" : "thermometer.medium.slash")
                    .resizable()
                    .frame(width: 32, height: 32)
                Text("Heat \(bleManager.heatStatus ? "On" : "Off")")
                    .bold()
                    .font(.headline)
                    .foregroundStyle(bleManager.heatStatus ? Color.red : Color.primary)
            }
            Spacer()
            VStack {
                Text(bleManager.peripheral.name ??  "Unnamed")
                    .font(.largeTitle)
                    .padding()
                Text("Current: \(bleManager.currentTemperature)°C")
                    .bold()
                    .font(.title)
                Text("Selected: \(bleManager.selectedTemperature)°C")
                    .font(.title)
            }
            Spacer()
            VStack {
                Image(systemName: bleManager.airStatus ? "humidifier.and.droplets.fill" : "humidifier.and.droplets")
                    .resizable()
                    .frame(width: 32, height: 32)
                    .onTapGesture {
                        bleManager.toggleAirPump()
                    }
                Text("Air \(bleManager.airStatus ? "On" : "Off")")
                    .bold()
                    .font(.headline)
                    .foregroundStyle(bleManager.airStatus ? Color.blue : Color.primary)
            }
            Spacer()
        }.padding()
    }
}

#Preview {
    DeviceDetailsHeaderView()
}
