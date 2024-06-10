//
//  DeviceSelectionView.swift
//  sbcontrol
//
//  Created by Lukas Fülling on 6/9/24.
//

import SwiftUI

struct DeviceSelectionView: View {
    @EnvironmentObject private var bleManager: BLEManager
    
    @State private var selectedItemId: UUID?

    var body: some View {
        NavigationView {
            List(selection: Binding(get: {true}, set: {_ in})) {
                Label {
                    Text("Connect")
                } icon: {
                    Image(systemName: "antenna.radiowaves.left.and.right")
                }.tag(true)
            }.listStyle(.sidebar)
            
            List(selection: $selectedItemId) {
                Section {
                    ForEach(bleManager.peripherals, id: \.identifier) { peripheral in
                        DeviceSelectionRowView(peripheral: peripheral)
                            .tag(peripheral.identifier)
                    }
                } header: {
                    Text("Found Devices")
                }
            }.navigationTitle("Device Selection")
        }
    }
}

#Preview {
    DeviceSelectionView()
}
