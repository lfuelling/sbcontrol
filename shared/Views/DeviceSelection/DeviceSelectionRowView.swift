//
//  DeviceSelectionRowView.swift
//  sbcontrol
//
//  Created by Lukas Fülling on 6/9/24.
//

import SwiftUI
import CoreBluetooth

struct DeviceSelectionRowView: View {
    @EnvironmentObject private var bleManager: BLEManager
    
    var peripheral: CBPeripheral
    
    @State private var hovering = false
    
    var body: some View {
        Button {
            self.bleManager.connectDevice(peripheral: peripheral)
        } label: {
            HStack {
                Text(peripheral.name ?? "Unnamed")
                    .fontWeight(hovering ? .bold : .regular)
                Spacer()
            }
        }
#if !os(watchOS)
        .onHover { hovering in
            self.hovering = hovering
        }
#endif

#if os(macOS)
        .onChange(of: hovering) {
            DispatchQueue.main.async {
                if(hovering) {
                    NSCursor.pointingHand.push()
                } else {
                    NSCursor.pop()
                }
            }
        }
        .padding(4)
        .buttonStyle(LinkButtonStyle())
#endif
    }
}

