//
//  DeviceDetailsView.swift
//  sbcontrol
//
//  Created by Lukas Fülling on 6/9/24.
//

import SwiftUI

struct DeviceDetailsView: View {
    @EnvironmentObject private var bleManager: BLEManager
    
    enum MenuItem: Hashable {
        case control, settings
    }
    
    @State private var selectedItem: MenuItem = .control
    
    var body: some View {
        NavigationStack {
            if let peripheral = bleManager.peripheral, bleManager.connected {
                let titleString = "\(bleManager.deviceDetermination.value): \(peripheral.name ?? "Unnamed")"
                
                TabView {
                    VStack {
                        DeviceControlsView()
                        Divider()
                        DeviceControlChartView()
                        Spacer()
                    }
                    .tabItem {
                        Label {
                            Text("Device Control")
                        } icon: {
                            Image(systemName: "slider.horizontal.3")
                        }.tag(MenuItem.control)
                    }
                    
                    DeviceSettingsView().tabItem {
                        Label {
                            Text("Device Settings")
                        } icon: {
                            Image(systemName: "gearshape.2")
                        }.tag(MenuItem.settings)
                    }
                }
                .navigationTitle(titleString)
#if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
#endif
                .toolbar {
#if os(macOS)
                    //TODO: remove this macOS-specific block when navigationTitle is rendered on macOS as well.
                    ToolbarItem(placement: .navigation) {
                        Text(titleString)
                            .bold()
                    }
#endif
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            bleManager.disconnect()
                        } label: {
                            Label {
                                Text("Disconnect")
                            } icon: {
                                Image(systemName: "door.left.hand.open")
                            }
                        }
                    }
                }
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
