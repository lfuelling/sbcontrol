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
        NavigationView {
            // sidebar
            List(selection: $selectedItem) {
                Label {
                    Text("Device Control")
                } icon: {
                    Image(systemName: "slider.horizontal.3")
                }.tag(MenuItem.control)
                Label {
                    Text("Device Settings")
                } icon: {
                    Image(systemName: "gearshape.2")
                }.tag(MenuItem.settings)
            }.listStyle(.sidebar)
            
            // main content
            VStack {
                switch(selectedItem) {
                case .control:
                    DeviceControlView()
                case .settings:
                    DeviceSettingsView()
                }
            }.toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        bleManager.disconnect()
                    } label: {
                        Label {
                            Text("Disconnect")
                        } icon: {
                            Image(systemName: "antenna.radiowaves.left.and.right.slash")
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    DeviceDetailsView()
}
