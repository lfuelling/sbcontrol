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
        HStack {
            Text(peripheral.name ?? "Unnamed")
                .fontWeight(hovering ? .bold : .regular)
            
            Spacer()
            Button {
                self.bleManager.connectDevice(peripheral: peripheral)
            } label: {
                Text("Connect")
            }
        }
        .onHover(perform: {hovering in
            self.hovering = hovering
        })
    }
}

