//
//  ContentView.swift
//  sbcontrol
//
//  Created by Lukas Fülling on 6/8/24.
//

import SwiftUI
import CoreBluetooth

struct ContentView: View {
    @ObservedObject var bleManager = BLEManager()
    
    var body: some View {
        if bleManager.peripheral == nil {
            VStack {
                Text("BLE Devices")
                List(bleManager.peripherals, id: \.identifier) { peripheral in
                    HStack {
                        Text(peripheral.name ?? "Unnamed")
                        Spacer()
                        Button(action: {
                            self.bleManager.connectDevice(peripheral: peripheral)
                        }) {
                            Text("Connect")
                        }
                    }
                }
            }
        } else {
            VStack {
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
                    Spacer()
                }
                Spacer()
            }
        }
    }
}

#Preview {
    ContentView()
}
