//
//  DeviceControlView.swift
//  sbcontrol
//
//  Created by Lukas Fülling on 6/10/24.
//

import SwiftUI

struct DeviceControlView: View {
    @EnvironmentObject private var bleManager: BLEManager

    var body: some View {
        VStack {
            DeviceControlHeaderView()
            Divider()
            DeviceControlChartView()
            Spacer()
        }.navigationTitle("Device Control")
    }
}

#Preview {
    DeviceControlView()
}
