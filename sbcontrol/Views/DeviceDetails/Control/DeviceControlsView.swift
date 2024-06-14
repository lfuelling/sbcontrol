//
//  DeviceControlHeaderView.swift
//  sbcontrol
//
//  Created by Lukas Fülling on 6/10/24.
//

import SwiftUI

struct DeviceControlsView: View {
    @EnvironmentObject private var bleManager: BLEManager
    
    var body: some View {
#if os(macOS)
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
#else
        VStack {
            DeviceControlsBatterySection()
            DeviceControlsTemperatureSection()
            DeviceControlsHeatButton()
            DeviceControlsAirButton()
        }.padding()
#endif
    }
}

#Preview {
    DeviceControlsView()
}
