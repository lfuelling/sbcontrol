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
#if os(macOS)
    var body: some View {
        NavigationView {
            List {
                Label {
                    Text("Connect")
                } icon: {
                    Image(systemName: "antenna.radiowaves.left.and.right")
                }.foregroundColor(.secondary)
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
            }
            .navigationTitle("Device Selection")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Label {
                        Text("Scanning…")
                    } icon: {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .scaleEffect(0.6)
                    }
                }
            }
        }
    }
    #else
    var body: some View {
        NavigationView {
            List(selection: $selectedItemId) {
                Section {
                    ForEach(bleManager.peripherals, id: \.identifier) { peripheral in
                        DeviceSelectionRowView(peripheral: peripheral)
                            .tag(peripheral.identifier)
                    }
                } header: {
                    Text("Found Devices")
                }
            }
            .navigationTitle("Device Selection")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Label {
                        Text("Scanning…")
                    } icon: {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .scaleEffect(0.6)
                    }
                }
            }
        }
    }
    #endif
}

#Preview {
    DeviceSelectionView()
}
