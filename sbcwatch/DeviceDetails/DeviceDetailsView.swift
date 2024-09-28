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
        
    enum Tabs {
        case temperature, info
    }
    
    @State private var selectedTab: Tabs = .temperature

    var body: some View {
        if !deviceState.dataLoadingFinished {
            LoaderView()
        } else {
            if deviceState.peripheral != nil {
                DeviceControlsView()
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
