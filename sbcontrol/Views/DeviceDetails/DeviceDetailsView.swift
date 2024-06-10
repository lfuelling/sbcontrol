//
//  DeviceDetailsView.swift
//  sbcontrol
//
//  Created by Lukas Fülling on 6/9/24.
//

import SwiftUI

struct DeviceDetailsView: View {
    @EnvironmentObject private var bleManager: BLEManager

    var body: some View {
        VStack {
            if(bleManager.connected) {
                DeviceDetailsHeaderView()
                Divider()
                DeviceDetailsChartView()
                Spacer()
            } else {
                ProgressView().progressViewStyle(.circular)
            }
        }.navigationTitle("Device Control")
    }
}

#Preview {
    DeviceDetailsView()
}
