//
//  DeviceControlsAirButton.swift
//  sbcontrol
//
//  Created by Lukas Fülling on 6/11/24.
//

import SwiftUI

fileprivate struct Content: View {
    @EnvironmentObject private var bleManager: BLEManager
    
    var body: some View {
        VStack {
            Image(systemName: bleManager.airStatus ? "humidifier.and.droplets.fill" : "humidifier.and.droplets")
                .resizable()
                .frame(width: 32, height: 32)
            Text("Air \(bleManager.airStatus ? "On" : "Off")")
                .bold()
                .font(.headline)
                .foregroundStyle(bleManager.airStatus ? Color.blue : Color.primary)
        }
    }
}

struct DeviceControlsAirButton: View {
    @EnvironmentObject private var bleManager: BLEManager
    
    var body: some View {
        Button {
            let result = bleManager.toggleAirPump()
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
        }.disabled(!bleManager.deviceDetermination.hasAir)
    }
}

#Preview {
    DeviceControlsAirButton()
}
