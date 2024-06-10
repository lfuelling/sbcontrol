//
//  BLEManager.swift
//  sbcontrol
//
//  Created by Lukas Fülling on 6/8/24.
//

import SwiftUI
import Combine
import CoreBluetooth

class BLEManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    @AppStorage("graphMaxEntries") private var graphMaxEntries: Int = 300
    
    var centralManager: CBCentralManager!
    var peripheral: CBPeripheral!
    
    @Published var peripherals: [CBPeripheral] = []
    
    @Published var connected = false
    @Published var selectedTemperature = -1
    @Published var currentTemperature = -1
    @Published var airStatus = false
    @Published var heatStatus = false
    
    private var graphTimer: Timer?
    private var currentTemperatureGraphSeries: [GraphView.Datapoint] = []
    private var selectedTemperatureGraphSeries: [GraphView.Datapoint] = []
    private var airStatusGraphSeries: [GraphView.Datapoint] = []
    private var heaterStatusGraphSeries: [GraphView.Datapoint] = []
    var graphSeries: [GraphView.DataSeries] {
        let currentTemperatureSeries = GraphView.DataSeries(label: "Current Temperature (°C)",
                                                            data: self.currentTemperatureGraphSeries)
        let selectedTemperatureSeries = GraphView.DataSeries(label: "Selected Temperature (°C)",
                                                             data: self.selectedTemperatureGraphSeries)
        let airStatusSeries = GraphView.DataSeries(label: "Air Pump",
                                                   data: self.airStatusGraphSeries,
                                                   booleanValue: true,
                                                   color: .blue)
        let heaterStatusSeries = GraphView.DataSeries(label: "Heater",
                                                      data: self.heaterStatusGraphSeries,
                                                      booleanValue: true,
                                                      color: .red)
        return [currentTemperatureSeries, selectedTemperatureSeries, airStatusSeries, heaterStatusSeries]
    }
    
    override init() {
        log.debug("Initializing…")
        super.init()
        self.graphTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.createGraphEntry()
        }
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
    
    fileprivate func createGraphEntry() {
        log.debug("Adding graph entry…")
        let entryDate = Date.now.timeIntervalSince1970
        self.currentTemperatureGraphSeries.append(GraphView.Datapoint(time: entryDate,
                                                                      value: Double(self.currentTemperature)))
        self.selectedTemperatureGraphSeries.append(GraphView.Datapoint(time: entryDate,
                                                                       value: Double(self.selectedTemperature)))
        self.airStatusGraphSeries.append(GraphView.Datapoint(time: entryDate,
                                                             value: self.airStatus ? 1 : 0))
        self.heaterStatusGraphSeries.append(GraphView.Datapoint(time: entryDate,
                                                                value: self.heatStatus ? 1 : 0))
        
        if(currentTemperatureGraphSeries.count > graphMaxEntries) {
            currentTemperatureGraphSeries.remove(at: 0)
        }
        if(selectedTemperatureGraphSeries.count > graphMaxEntries) {
            selectedTemperatureGraphSeries.remove(at: 0)
        }
        if(airStatusGraphSeries.count > graphMaxEntries) {
            airStatusGraphSeries.remove(at: 0)
        }
        if(heaterStatusGraphSeries.count > graphMaxEntries) {
            heaterStatusGraphSeries.remove(at: 0)
        }
        DispatchQueue.main.async {
            withAnimation {
                self.objectWillChange.send()
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
                self.heatStatus = heaterStatus
                log.info("Received heater status: \(heaterStatus)")
                
                let airValue = Int(value[1])
                let airPumpStatus = (airValue & 0x0030) != 0
                self.airStatus = airPumpStatus
                log.info("Received air pump status: \(heaterStatus)")
            default:
                break
            }
        }
    }
    
    func toggleAirPump() {
        log.error("TODO!")
    }
    
    func toggleHeat() {
        log.error("TODO!")
    }
    
    func decreaseTemperature() {
        log.error("TODO!")
    }
    
    func increaseTemperature() {
        log.error("TODO!")
    }
}
