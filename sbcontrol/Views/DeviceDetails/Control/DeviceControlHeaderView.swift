//
//  DeviceControlHeaderView.swift
//  sbcontrol
//
//  Created by Lukas Fülling on 6/10/24.
//

import SwiftUI

struct DeviceControlHeaderView: View {
    @EnvironmentObject private var bleManager: BLEManager
    
    var body: some View {
        HStack {
            Spacer()
            Button {
                bleManager.toggleHeat()
            } label: {
                VStack {
                    Image(systemName: bleManager.heatStatus ? "thermometer.high" : "thermometer.medium.slash")
                        .resizable()
                        .frame(width: 32, height: 32)
                    Text("Heat \(bleManager.heatStatus ? "On" : "Off")")
                        .bold()
                        .font(.headline)
                        .foregroundStyle(bleManager.heatStatus ? Color.red : Color.primary)
                }.padding()
            }
            Spacer()
            VStack {
                Text(bleManager.peripheral?.name ??  "Unnamed")
                    .font(.largeTitle)
                    .padding()
                HStack {
                    Button {
                        bleManager.decreaseTemperature()
                    } label: {
                        Text("-") // TODO: increase size
                    }
                    VStack {
                        Text("Current: \(bleManager.currentTemperature)°C")
                            .bold()
                            .font(.title)
                        Text("Selected: \(bleManager.selectedTemperature)°C")
                            .font(.title)
                    }
                    Button {
                        bleManager.increaseTemperature()
                    } label: {
                        Text("+") // TODO: increase size
                    }
                }
            }
            Spacer()
            Button {
                bleManager.toggleAirPump()
            } label: {
                VStack {
                    Image(systemName: bleManager.airStatus ? "humidifier.and.droplets.fill" : "humidifier.and.droplets")
                        .resizable()
                        .frame(width: 32, height: 32)
                    Text("Air \(bleManager.airStatus ? "On" : "Off")")
                        .bold()
                        .font(.headline)
                        .foregroundStyle(bleManager.airStatus ? Color.blue : Color.primary)
                }.padding()
            }
            Spacer()
        }.padding()
    }
}

#Preview {
    DeviceControlHeaderView()
}
