//
//  DeviceDetailsView.swift
//  sbcontrol
//
//  Created by Lukas Fülling on 9/26/24.
//  Copyright © 2024 Lerk Tech. All rights reserved.
//

import SwiftUI

struct DeviceDetailsView: View {
    @EnvironmentObject private var bleManager: BLEManager
    @EnvironmentObject private var deviceState: DeviceState
    
    enum MenuItem: Hashable {
        case control, settings
    }
    
    @State private var selectedItem: MenuItem = .control
    
    var body: some View {
        if !deviceState.dataLoadingFinished {
            LoaderView()
        } else {
            if let peripheral = deviceState.peripheral {
                let titleString = "\(deviceState.deviceDetermination.value): \(peripheral.name ?? "Unnamed")"
                
                List {
                    DeviceDetailsTemperatureSection()
                    DeviceDetailsControlsSection()
                }
                .listStyle(.carousel)
                .navigationTitle(titleString)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
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
                        }.padding()
                    })
                    ToolbarItem(placement: .bottomBar) {
                        Button {
                            bleManager.disconnect(peripheral: deviceState.peripheral)
                        } label: {
                            Label {
                                Text("Disconnect")
                            } icon: {
                                Image(systemName: "door.left.hand.open")
                            }
                        }
                    }
                }
            } else {
                VStack {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(.circular)
                    Spacer()
                }.navigationTitle("Connecting…")
            }
        }
    }
}

#Preview {
    DeviceDetailsView()
}
