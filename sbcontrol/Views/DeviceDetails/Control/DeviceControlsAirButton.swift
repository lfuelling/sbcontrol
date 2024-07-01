//
//  DeviceControlsAirButton.swift
//  sbcontrol
//
//  Created by Lukas Fülling on 6/11/24.
//

import SwiftUI

fileprivate struct Content: View {
    @EnvironmentObject private var deviceState: DeviceState
    
    var body: some View {
        VStack {
            Image(systemName: deviceState.airStatus ? "humidifier.and.droplets.fill" : "humidifier.and.droplets")
                .resizable()
                .frame(width: 32, height: 32)
            Text("Air \(deviceState.airStatus ? "On" : "Off")")
                .bold()
                .font(.headline)
                .foregroundStyle(deviceState.airStatus ? Color.blue : Color.primary)
        }
    }
}

struct DeviceControlsAirButton: View {
    @EnvironmentObject private var deviceState: DeviceState
    
    var body: some View {
        Button {
            let _ = deviceState.toggleAirPump()
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
        }.disabled(!deviceState.deviceDetermination.hasAir || deviceState.writingValue)
    }
}

#Preview {
    DeviceControlsAirButton()
}
