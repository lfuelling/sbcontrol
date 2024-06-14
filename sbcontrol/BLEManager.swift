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
    
    @Published var writingValue = false
    @Published var connected = false
    @Published var bluetoothNotAvailable = false
    @Published var selectedTemperature = -1
    @Published var currentTemperature = -1
    @Published var airStatus = false
    @Published var heatStatus = false
    @Published var deviceDetermination: DeviceDetermination = .unknown
    @Published var hoursOfOperation = -1
    @Published var batteryPercent = -1
    @Published var powerState = false
    @Published var serialNumber = ""
    
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
    
    fileprivate func resetState() {
        log.info("Resetting State…")
        withAnimation {
            self.deviceDetermination = .unknown
            self.connected = false
            self.peripheral = nil
            self.currentTemperatureGraphSeries = []
            self.selectedTemperatureGraphSeries = []
            self.airStatusGraphSeries = []
            self.heaterStatusGraphSeries = []
            self.powerState = false
            self.batteryPercent = -1
            self.currentTemperature = -1
            self.selectedTemperature = -1
            self.airStatus = false
            self.heatStatus = false
            self.writingValue = false
            self.serialNumber = ""
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
        self.deviceDetermination = .unknown
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
    
    fileprivate func tryDeviceDetermination(for characteristic: CBCharacteristic) {
        let characteristicId = characteristic.uuid.uuidString.lowercased()
        if(deviceDetermination == .unknown) {
            if (Volcano.compatibleIds.contains(characteristicId)) {
                log.info("Device detected as Volcano!")
                withAnimation {
                    deviceDetermination = .volcano
                }
            } else if(Crafty.compatibleIds.contains(characteristicId)) {
                log.info("Device detected as Crafty!")
                withAnimation {
                    deviceDetermination = .crafty
                }
            } else {
                log.debug("Unable to determine device!")
                withAnimation {
                    deviceDetermination = .unknown
                }
            }
        }
    }
    
    fileprivate func notifyIfNeeded(about characteristic: CBCharacteristic) {
        let characteristicId = characteristic.uuid.uuidString.lowercased()
        if (Volcano.compatibleIds.contains(characteristicId) ||
            Crafty.compatibleIds.contains(characteristicId)) {
            log.info("Activating notifications for \(characteristicId)…")
            peripheral.setNotifyValue(true, for: characteristic)
            log.debug("Reading initial value of \(characteristic.uuid.uuidString.lowercased())…")
            peripheral.readValue(for: characteristic)
        } else {
            log.debug("Unknown characteristic: \(characteristicId)")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                tryDeviceDetermination(for: characteristic)
                notifyIfNeeded(about: characteristic)
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
            let characteristicUUID = characteristic.uuid.uuidString.lowercased()
            if let handle = Volcano.valueHandlers[characteristicUUID] {
                handle(value, self)
            } else if let handle = Crafty.valueHandlers[characteristicUUID] {
                handle(value, self)
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
        
        withAnimation {
            writingValue = false
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
        self.resetState()
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
        switch(deviceDetermination) {
        case .volcano:
            if airStatus {
                return writeSingleValue(uuidString: Volcano.airOffId,
                                        logMessage: "Writing air OFF…",
                                        errorMessage: "Unable to write air OFF!")
            } else {
                return writeSingleValue(uuidString: Volcano.airOnId,
                                        logMessage: "Writing air ON…",
                                        errorMessage: "Unable to write air ON!")
            }
        case .crafty:
            log.warning("TODO!")
        default:
            log.debug("Unknown device!")
        }
        return false
    }
    
    func toggleHeat() -> Bool {
        switch(deviceDetermination) {
        case .volcano:
            if heatStatus {
                return writeSingleValue(uuidString: Volcano.heatOffId,
                                        logMessage: "Writing heat OFF…",
                                        errorMessage: "Unable to write heat OFF!")
            } else {
                return writeSingleValue(uuidString: Volcano.heatOnId,
                                        logMessage: "Writing heat ON…",
                                        errorMessage: "Unable to write heat ON!")
            }
        case .crafty:
            if heatStatus {
                return writeSingleValue(uuidString: Crafty.heaterOffId,
                                        logMessage: "Writing heat OFF…",
                                        errorMessage: "Unable to write heat OFF!")
            } else {
                return writeSingleValue(uuidString: Crafty.heaterOnId,
                                        logMessage: "Writing heat ON…",
                                        errorMessage: "Unable to write heat ON!")
            }
        default:
            log.debug("Unknown device!")
        }
        return false
    }
    
    fileprivate func writeSingleValue(uuidString: String, logMessage: String, errorMessage: String) -> Bool {
        let uuid = CBUUID(string: uuidString)
        if let services = peripheral.services {
            if let characteristic = services.flatMap({$0.characteristics ?? []}).first(where: {$0.uuid == uuid}) {
                log.info(logMessage)
                switch(deviceDetermination) {
                case .volcano:
                    peripheral.writeValue(Data(repeating: 1, count: 1), for: characteristic, type: .withResponse)
                    return true
                case .crafty:
                    var value: Int16 = Int16(1)
                    let data = Data(bytes: &value, count: MemoryLayout.size(ofValue: value))
                    peripheral.writeValue(data, for: characteristic, type: .withResponse)
                    return true
                default:
                    log.debug("Unknown device!")
                }
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
        if let services = peripheral.services {
            let characteristics = services.flatMap({$0.characteristics ?? []})
            log.info("Writing temperature \(temperature)°C…")
            withAnimation {
                writingValue = true
            }
            switch(deviceDetermination) {
            case .volcano: 
                if let characteristic = characteristics.first(where: {$0.uuid == CBUUID(string: Volcano.selectedTempId)}) {
                    let scaledIntTemp = Int32(temperature * 10)
                    let data = withUnsafeBytes(of: scaledIntTemp.littleEndian) { Data($0) }
                    peripheral.writeValue(data, for: characteristic, type: .withResponse)
                    return true
                }
            case .crafty:
                if let characteristic = characteristics.first(where: {$0.uuid == CBUUID(string: Crafty.selectedTempId)}) {
                    let scaledIntTemp = Int16(temperature * 10)
                    let data = withUnsafeBytes(of: scaledIntTemp.littleEndian) { Data($0) }
                    peripheral.writeValue(data, for: characteristic, type: .withResponse)
                    return true
                }
            default:
                log.debug("Unknown device!")
            }
        }
        
        log.error("Unable to write temperature!")
        return false
    }
}
