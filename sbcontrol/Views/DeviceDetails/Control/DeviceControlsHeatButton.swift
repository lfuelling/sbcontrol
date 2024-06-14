//
//  DeviceControlsFunctionsView.swift
//  sbcontrol
//
//  Created by Lukas Fülling on 6/11/24.
//

import SwiftUI

fileprivate struct Content: View {
    @EnvironmentObject private var bleManager: BLEManager
    
    var body: some View {
        VStack {
            Image(systemName: bleManager.heatStatus ? "thermometer.high" : "thermometer.medium.slash")
                .resizable()
                .frame(width: 32, height: 32)
            Text("Heat \(bleManager.heatStatus ? "On" : "Off")")
                .bold()
                .font(.headline)
                .foregroundStyle(bleManager.heatStatus ? Color.red : Color.primary)
        }
    }
}

struct DeviceControlsHeatButton: View {
    @EnvironmentObject private var bleManager: BLEManager
    
    var body: some View {
        Button {
            let result = bleManager.toggleHeat()
        } label: {
#if os(iOS)
            HStack {
                Spacer()
                Content()
                Spacer()
            }.padding()
#else
            Content().padding()
#endif
        }.disabled(!bleManager.deviceDetermination.hasHeat)
    }
}

#Preview {
    DeviceControlsHeatButton()
}
