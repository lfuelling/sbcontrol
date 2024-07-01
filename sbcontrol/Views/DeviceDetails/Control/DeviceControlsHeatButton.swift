//
//  DeviceControlsFunctionsView.swift
//  sbcontrol
//
//  Created by Lukas Fülling on 6/11/24.
//

import SwiftUI

fileprivate struct Content: View {
    @EnvironmentObject private var deviceState: DeviceState
    
    var body: some View {
        VStack {
            Image(systemName: deviceState.heatStatus ? "thermometer.high" : "thermometer.medium.slash")
                .resizable()
                .frame(width: 32, height: 32)
            Text("Heat \(deviceState.heatStatus ? "On" : "Off")")
                .bold()
                .font(.headline)
                .foregroundStyle(deviceState.heatStatus ? Color.red : Color.primary)
        }
    }
}

struct DeviceControlsHeatButton: View {
    @EnvironmentObject private var deviceState: DeviceState
    
    var body: some View {
        Button {
            let _ = deviceState.toggleHeat()
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
        }.disabled(!deviceState.deviceDetermination.hasHeat || deviceState.writingValue)
    }
}

#Preview {
    DeviceControlsHeatButton()
}
