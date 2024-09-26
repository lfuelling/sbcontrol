//
//  ContentView.swift
//  sbcwatch Watch App
//
//  Created by Lukas Fülling on 9/26/24.
//

import SwiftUI
import CoreBluetooth

struct ContentView: View {
    
    @EnvironmentObject private var bleManager: BLEManager
    
    @StateObject private var deviceState: DeviceState = DeviceState()
    @StateObject private var metricsState: MetricsState = MetricsState()
    
    var body: some View {
        NavigationStack {
            if !bleManager.connected {
                DeviceSelectionView()
                    .onAppear {
                        bleManager.onConnect = { peripheral in
                            deviceState.resetState()
                            metricsState.resetState()
                            deviceState.peripheral = peripheral
                            deviceState.peripheral.delegate = deviceState
                            deviceState.peripheral.discoverServices(nil)
                            metricsState.createTimer(deviceState: deviceState)
                        }
                        bleManager.onDisconnect = {
                            metricsState.cancelTimer()
                            log.debug("Resetting states…")
                            deviceState.resetState()
                            metricsState.resetState()
                        }
                    }
            } else {
                DeviceDetailsView()
                    .environmentObject(deviceState)
                    .environmentObject(metricsState)
            }
        }
    }
}

#Preview {
    ContentView()
}
