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
        NavigationStack {
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
#if os(macOS)
                            .scaleEffect(0.6)
#endif
                    }
                }
            }
        }.alert("Error", isPresented: Binding(get: {bleManager.bluetoothNotAvailable}, set: {_ in})) {
            Button {
                exit(0)
            } label: {
                Text("Quit Application")
            }
        } message: {
            Text("Bluetooth is not available, the application can't be used.")
        }
    }
}

#Preview {
    DeviceSelectionView()
}
