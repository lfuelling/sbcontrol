//
//  DeviceControlHeaderView.swift
//  sbcontrol
//
//  Created by Lukas Fülling on 6/10/24.
//

import SwiftUI

struct DeviceControlsView: View {
    @EnvironmentObject private var deviceState: DeviceState
    
    var body: some View {
#if os(macOS)
        if(deviceState.deviceDetermination.hasAir) {
            HStack {
                DeviceControlsHeatButton()
                Spacer()
                VStack(spacing: 2) {
                    DeviceControlsBatterySection()
                    DeviceControlsTemperatureSection()
                }
                Spacer()
                DeviceControlsAirButton()
            }.padding()
        } else {
            VStack {
                DeviceControlsBatterySection()
                DeviceControlsHeatButton()
                DeviceControlsTemperatureSection()
            }.padding()
        }
#else
        VStack {
            DeviceControlsBatterySection()
            DeviceControlsTemperatureSection()
            DeviceControlsHeatButton()
            if(deviceState.deviceDetermination.hasAir) {
                DeviceControlsAirButton()
            }
        }.padding()
#endif
    }
}

#Preview {
    DeviceControlsView()
}
