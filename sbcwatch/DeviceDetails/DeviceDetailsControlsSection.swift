//
//  DeviceDetailsControlsSection.swift
//  sbcontrol
//
//  Created by Lukas Fülling on 9/26/24.
//  Copyright © 2024 Lerk Tech. All rights reserved.
//

import SwiftUI

struct DeviceDetailsControlsSection: View {
    @EnvironmentObject private var deviceState: DeviceState

    var body: some View {
        Section {
            DeviceControlsHeatButton()
            if(deviceState.deviceDetermination.hasAir) {
                DeviceControlsAirButton()
            }
        } header: {
            Text("Controls")
        }
    }
}
