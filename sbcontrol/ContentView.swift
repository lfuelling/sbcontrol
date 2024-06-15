//
//  ContentView.swift
//  sbcontrol
//
//  Created by Lukas Fülling on 6/8/24.
//

import SwiftUI
import CoreBluetooth

struct ContentView: View {
    @EnvironmentObject private var bleManager: BLEManager
    
    var body: some View {
        if bleManager.peripheral == nil {
            DeviceSelectionView()
        } else if !bleManager.dataLoadingFinished {
            LoaderView()
        } else {
            DeviceDetailsView()
        }
    }
}

#Preview {
    ContentView()
}
