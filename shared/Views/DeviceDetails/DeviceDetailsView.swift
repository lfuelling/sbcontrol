//
//  DeviceDetailsView.swift
//  sbcontrol
//
//  Created by Lukas Fülling on 6/9/24.
//

import SwiftUI

struct DeviceDetailsView: View {
    @EnvironmentObject private var bleManager: BLEManager
    @EnvironmentObject private var deviceState: DeviceState
    
    enum MenuItem: Hashable {
        case control, settings
    }
    
    @State private var selectedItem: MenuItem = .control
    
    var body: some View {
        if !deviceState.dataLoadingFinished {
            LoaderView()
        } else {
            if let peripheral = deviceState.peripheral {
                let titleString = "\(deviceState.deviceDetermination.value): \(peripheral.name ?? "Unnamed")"
                
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
                    //TODO: remove this macOS-specific block when navigationTitle is rendered on macOS when a TabView is in the Toolbar as well.
                    ToolbarItem(placement: .navigation) {
                        Text(titleString)
                            .bold()
                    }
    #endif
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            bleManager.disconnect(peripheral: deviceState.peripheral)
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
