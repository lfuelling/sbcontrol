//
//  BLEManager.swift
//  sbcontrol
//
//  Created by Lukas Fülling on 6/8/24.
//

import SwiftUI
import CoreBluetooth

class BLEManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    var centralManager: CBCentralManager!
    var peripheral: CBPeripheral!
    
    @Published var peripherals: [CBPeripheral] = []
    
    @Published var connected = false
    @Published var selectedTemperature = -1
    @Published var currentTemperature = -1
    @Published var airStatue = false
    @Published var heatStatue = false
    
    override init() {
        super.init()
        log.info("Starting scan…")
        centralManager = CBCentralManager(delegate: self, queue: nil)
        centralManager.delegate = self
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        } else {
            log.error("Bluetooth not available!")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if let idx = self.peripherals.firstIndex(of: peripheral) {
            withAnimation {
                self.peripherals[idx] = peripheral
            }
        } else if peripheral.name != nil && Int(truncating: RSSI) > -80 {
            log.info("Found device \"\(peripheral.name ?? "Unnamed")\", with \(RSSI)…")
            withAnimation {
                self.peripherals.append(peripheral)
            }
        }
    }
    
    func connectDevice(peripheral: CBPeripheral) {
        withAnimation {
            self.peripheral = peripheral
        }
        Task {
            log.info("Stopping scan…")
            self.centralManager.stopScan()
            self.peripheral.delegate = self
            log.info("Connecting to \"\(peripheral.name ?? "Unnamed")\"…")
            self.centralManager.connect(self.peripheral, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        self.connected = true
        self.peripheral.discoverServices(nil)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service in peripheral.services! {
            self.peripheral.discoverIncludedServices(nil, for: service)
            self.peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverIncludedServicesFor parentService: CBService, error: Error?) {
        if let includedServices = parentService.includedServices {
            for service in includedServices {
                self.peripheral.discoverIncludedServices(nil, for: service)
                self.peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                switch characteristic.uuid.uuidString.lowercased() {
                case "10110001-5354-4f52-5a26-4249434b454c", // Current temperature
                     "10110003-5354-4f52-5a26-4249434b454c", // Set temperature
                    "1010000c-5354-4f52-5a26-4249434b454c": // stat1
                    log.info("Activating notifications for \(characteristic.uuid.uuidString)…")
                    peripheral.setNotifyValue(true, for: characteristic)
                    peripheral.readValue(for: characteristic)
                default:
                    break
                }
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let value = characteristic.value {
            switch characteristic.uuid.uuidString.lowercased() {
            case "10110001-5354-4f52-5a26-4249434b454c": // Current temperature
                let intValue = UInt32(littleEndian: value.withUnsafeBytes { $0.load(as: UInt32.self) })
                let currentTemperature = Int(intValue / 10)
                log.info("Received current temperature: \(currentTemperature)")
                self.currentTemperature = currentTemperature
            case "10110003-5354-4f52-5a26-4249434b454c": // Set temperature
                let intValue = UInt32(littleEndian: value.withUnsafeBytes { $0.load(as: UInt32.self) })
                let selectedTemperature = Int(intValue / 10)
                log.info("Received selected temperature: \(selectedTemperature)")
                self.selectedTemperature = selectedTemperature
            case "1010000c-5354-4f52-5a26-4249434b454c": // stat1
                let heaterValue = Int(value[0])
                let heaterStatus = (heaterValue & 0x0020) != 0
                self.heatStatue = heaterStatus
                log.info("Received heater status: \(heaterStatus)")
                
                let airValue = Int(value[1])
                let airPumpStatus = (airValue & 0x0030) != 0
                self.airStatue = airPumpStatus
                log.info("Received air pump status: \(heaterStatus)")
            default:
                break
            }
        }
    }
    
    func toggleAirPump() {
        
    }
    
    // Implement other delegate methods as needed
}
