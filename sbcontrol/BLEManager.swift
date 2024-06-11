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
    @Published var bluetoothNotAvailable = false
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
                                                            data: self.currentTemperatureGraphSeries,
                                                            booleanValue: false,
                                                            color: Color.red,
                                                            symbol: .circle)
        let selectedTemperatureSeries = GraphView.DataSeries(label: "Selected Temperature (°C)",
                                                             data: self.selectedTemperatureGraphSeries,
                                                             booleanValue: false,
                                                             color: Color.green,
                                                             symbol: .diamond)
        let airStatusSeries = GraphView.DataSeries(label: "Air Pump",
                                                   data: self.airStatusGraphSeries,
                                                   booleanValue: true,
                                                   color: .blue,
                                                   symbol: .triangle)
        let heaterStatusSeries = GraphView.DataSeries(label: "Heater",
                                                      data: self.heaterStatusGraphSeries,
                                                      booleanValue: true,
                                                      color: .red,
                                                      symbol: .plus)
        return [currentTemperatureSeries, selectedTemperatureSeries, airStatusSeries, heaterStatusSeries]
    }
    
    override init() {
        log.debug("Initializing…")
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        centralManager.delegate = self
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
        if !peripherals.contains(peripheral) && peripheral.name != nil && Int(truncating: RSSI) > -80 {
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
        log.info("Connected to \"\(peripheral.name ?? "Unnamed")\"!")
        self.connected = true
        self.peripheral.discoverServices(nil)
        self.graphTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.createGraphEntry()
        }
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
                    "1010000c-5354-4f52-5a26-4249434b454c", // stat1 (airpump/heater status)
                    "1011000c-5354-4f52-5a26-4249434b454c", // auto shut off enabled
                    "1011000d-5354-4f52-5a26-4249434b454c", // auto shut off time
                    "10110015-5354-4f52-5a26-4249434b454c", // operation hours
                    "10110005-5354-4f52-5a26-4249434b454c", // led brightness
                    "10100008-5354-4f52-5a26-4249434b454c", // serial number
                    "10100003-5354-4f52-5a26-4249434b454c", // firmware version
                    "10100004-5354-4f52-5a26-4249434b454c", // ble firmware version
                    "1010000d-5354-4f52-5a26-4249434b454c", // stat2 (fahrenheit enabled 0x200, display on cooling 0x1000)
                    "1010000e-5354-4f52-5a26-4249434b454c": // stat3 (vibration enabled 0x400)
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
                log.info("Received current temperature: \(currentTemperature)°C")
                self.currentTemperature = currentTemperature
            case "10110003-5354-4f52-5a26-4249434b454c": // Set temperature
                let intValue = UInt32(littleEndian: value.withUnsafeBytes { $0.load(as: UInt32.self) })
                let selectedTemperature = Int(intValue / 10)
                log.info("Received selected temperature: \(selectedTemperature)°C")
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
            case "1011000c-5354-4f52-5a26-4249434b454c": // auto shut off enabled
                let intValue = UInt8(littleEndian: value.withUnsafeBytes { $0.load(as: UInt8.self) })
                log.info("Received auto shut off enabled: \(intValue)")
            case "1011000d-5354-4f52-5a26-4249434b454c": // auto shut off time
                let intValue = UInt16(littleEndian: value.withUnsafeBytes { $0.load(as: UInt16.self) })
                log.info("Received auto shut off time: \(intValue)")
            case "10110015-5354-4f52-5a26-4249434b454c": // operation hours
                let intValue = UInt32(littleEndian: value.withUnsafeBytes { $0.load(as: UInt32.self) })
                log.info("Received operation hours: \(intValue)")
            case "10110005-5354-4f52-5a26-4249434b454c": // led brightness
                let intValue = UInt16(littleEndian: value.withUnsafeBytes { $0.load(as: UInt16.self) })
                log.info("Received led brightness: \(intValue)")
            case "10100008-5354-4f52-5a26-4249434b454c": // serial number
                let intValue = UInt32(littleEndian: value.withUnsafeBytes { $0.load(as: UInt32.self) })
                log.info("Received serial number: \(intValue)")
            case "10100003-5354-4f52-5a26-4249434b454c": // firmware version
                let intValue = UInt32(littleEndian: value.withUnsafeBytes { $0.load(as: UInt32.self) })
                log.info("Received firmware version: \(intValue)")
            case "10100004-5354-4f52-5a26-4249434b454c": // ble firmware version
                let intValue = UInt32(littleEndian: value.withUnsafeBytes { $0.load(as: UInt32.self) })
                log.info("Received ble firmware version: \(intValue)")
            case "1010000d-5354-4f52-5a26-4249434b454c": // stat2 (fahrenheit enabled 0x200, display on cooling 0x1000)
                let intValue = UInt32(littleEndian: value.withUnsafeBytes { $0.load(as: UInt32.self) })
                log.info("Received stat2 (fahrenheit enabled 0x200, display on cooling 0x1000): \(intValue)")
            case "1010000e-5354-4f52-5a26-4249434b454c": // stat3 (vibration enabled 0x400)
                let intValue = UInt32(littleEndian: value.withUnsafeBytes { $0.load(as: UInt32.self) })
                log.info("Received stat3 (vibration enabled 0x400): \(intValue)")
            default:
                break
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            log.error("Error writing characteristic value: \(error.localizedDescription)")
        } else {
            log.info("Successfully wrote value for characteristic \(characteristic.uuid)!")
            peripheral.readValue(for: characteristic)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if let error = error {
            log.error("Failed to disconnect from peripheral: \(error)")
        } else {
            log.info("Disconnected from \"\(peripheral.name ?? "Unnamed")\"!")
        }
        log.debug("Cancelling timer…")
        self.graphTimer?.invalidate()
        self.graphTimer = nil
        withAnimation {
            self.connected = false
            self.peripheral = nil
        }
        log.info("Starting scan…")
        self.centralManager.scanForPeripherals(withServices: nil, options: nil)
    }
    
    func disconnect() {
        withAnimation {
            self.connected = false
        }
        if let peripheral = self.peripheral {
            log.info("Disconnecting from \"\(peripheral.name ?? "Unnamed")\"…")
            self.centralManager.cancelPeripheralConnection(peripheral)
        } else {
            log.warning("Unable to cancel peripheral connection!")
        }
    }
    
    func toggleAirPump() -> Bool {
        if airStatus {
            return writeSingleValue(uuidString: "10110014-5354-4f52-5a26-4249434b454c",
                                    logMessage: "Writing air OFF…",
                                    errorMessage: "Unable to write air OFF!")
        } else {
            return writeSingleValue(uuidString: "10110013-5354-4f52-5a26-4249434b454c",
                                    logMessage: "Writing air ON…",
                                    errorMessage: "Unable to write air ON!")
        }
    }
    
    func toggleHeat() -> Bool {
        if heatStatus {
            return writeSingleValue(uuidString: "10110010-5354-4f52-5a26-4249434b454c",
                                    logMessage: "Writing heat OFF…",
                                    errorMessage: "Unable to write heat OFF!")
        } else {
            return writeSingleValue(uuidString: "1011000f-5354-4f52-5a26-4249434b454c",
                                    logMessage: "Writing heat ON…",
                                    errorMessage: "Unable to write heat ON!")
        }
    }
    
    fileprivate func writeSingleValue(uuidString: String, logMessage: String, errorMessage: String) -> Bool {
        let uuid = CBUUID(string: uuidString)
        if let services = peripheral.services {
            if let characteristic = services.flatMap({$0.characteristics ?? []}).first(where: {$0.uuid == uuid}) {
                log.info(logMessage)
                peripheral.writeValue(Data(repeating: 1, count: 1), for: characteristic, type: .withResponse)
                return true
            }
        }
        log.error(errorMessage)
        return false
    }
    
    func decreaseTemperature() -> Bool {
        return writeTemperature(temperature: selectedTemperature - 1)
    }
    
    func increaseTemperature() -> Bool {
        return writeTemperature(temperature: selectedTemperature + 1)
    }
    
    fileprivate func writeTemperature(temperature: Int) -> Bool {
        let scaledIntTemp = Int32(temperature * 10)
        let data = withUnsafeBytes(of: scaledIntTemp.littleEndian) { Data($0) }
        let setTempUUID = CBUUID(string: "10110003-5354-4f52-5a26-4249434b454c")
        if let services = peripheral.services {
            if let characteristic = services.flatMap({$0.characteristics ?? []}).first(where: {$0.uuid == setTempUUID}) {
                log.info("Writing temperature \(temperature)°C…")
                peripheral.writeValue(data, for: characteristic, type: .withResponse)
                return true
            }
        }
        log.error("Unable to write temperature!")
        return false
    }
}
