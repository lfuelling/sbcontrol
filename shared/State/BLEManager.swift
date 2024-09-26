//
//  BLEManager.swift
//  sbcontrol
//
//  Created by Lukas Fülling on 6/8/24.
//

import SwiftUI
import Combine
import CoreBluetooth

class BLEManager: NSObject, ObservableObject, CBCentralManagerDelegate {
    var onConnect: ((CBPeripheral) -> Void)?
    var onDisconnect: (() -> Void)?
    
    var centralManager: CBCentralManager!
    
    @Published var peripherals: [CBPeripheral] = []
    
    @Published var connected = false
    @Published var bluetoothNotAvailable = false
    
    override init() {
        log.debug("Initializing…")
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        centralManager.delegate = self
    }
    
    fileprivate func resetState() {
        log.info("Resetting State…")
        withAnimation {
            self.connected = false
        }
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            log.info("Starting scan…")
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        } else {
            log.error("Bluetooth not available!")
            bluetoothNotAvailable = true
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let name = peripheral.name ?? "Unnamed"
        
        if !peripherals.contains(peripheral) && (
            Volcano.matchingName(name) ||
            Crafty.matchingName(name)
        ) {
            log.info("Found device \"\(name)\", with \(RSSI)…")
            withAnimation {
                self.peripherals.append(peripheral)
            }
        }
    }
    
    func connectDevice(peripheral: CBPeripheral) {
        log.info("Stopping scan…")
        self.centralManager.stopScan()
        log.info("Connecting to \"\(peripheral.name ?? "Unnamed")\"…")
        self.centralManager.connect(peripheral, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        log.info("Connected to \"\(peripheral.name ?? "Unnamed")\"!")
        self.connected = true
        onConnect?(peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if let error = error {
            log.error("Failed to disconnect from peripheral: \(error)")
        } else {
            log.info("Disconnected from \"\(peripheral.name ?? "Unnamed")\"!")
        }
        onDisconnect?()
        log.info("Starting scan…")
        self.centralManager.scanForPeripherals(withServices: nil, options: nil)
    }
    
    func disconnect(peripheral: CBPeripheral?) {
        withAnimation {
            self.connected = false
        }
        if let peripheral = peripheral {
            log.info("Disconnecting from \"\(peripheral.name ?? "Unnamed")\"…")
            self.centralManager.cancelPeripheralConnection(peripheral)
        } else {
            log.warning("Unable to cancel peripheral connection!")
        }
    }
}
