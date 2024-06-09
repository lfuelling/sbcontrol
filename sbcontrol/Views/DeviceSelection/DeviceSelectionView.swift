//
//  DeviceSelectionView.swift
//  sbcontrol
//
//  Created by Lukas Fülling on 6/9/24.
//

import SwiftUI

struct DeviceSelectionView: View {
    @EnvironmentObject private var bleManager: BLEManager

    var body: some View {
        VStack {
            List {
                Section {
                    ForEach(bleManager.peripherals, id: \.identifier) { peripheral in
                        DeviceSelectionRowView(peripheral: peripheral)
                    }
                } header: {
                    Text("Found Devices")
                }
            }
        }.navigationTitle("Device Selection")
    }
}

#Preview {
    DeviceSelectionView()
}
