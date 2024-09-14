//
//  DeviceState.swift
//  sbcontrol
//
//  Created by Lukas Fülling on 7/1/24.
//

import SwiftUI
import Combine
import CoreBluetooth

class DeviceState: NSObject, ObservableObject, CBPeripheralDelegate {
    var peripheral: CBPeripheral!
    
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
    @Published var deviceFirmwareVersion = ""
    @Published var deviceBLEFirmwareVersion = ""
    @Published var deviceLEDBrightness = -1
    @Published var deviceAutoShutoffTime = -1
    
    @Published var subscribedCharacteristics: [String] = []
    
    var dataLoadingFinished: Bool {
        get {
            switch(self.deviceDetermination) {
            case .unknown:
                return false
            case .crafty:
                return Crafty.subscribableIds.allSatisfy { elem in
                    subscribedCharacteristics.contains(elem)
                }
            case .volcano:
                return Volcano.subscribableIds.allSatisfy { elem in
                    subscribedCharacteristics.contains(elem)
                }
            }
        }
    }
    
    func resetState() {
        log.info("Resetting State…")
        withAnimation {
            self.subscribedCharacteristics = []
            self.deviceDetermination = .unknown
            self.connected = false
            self.peripheral = nil
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
            log.debug("Reading initial value of \(characteristic.uuid.uuidString.lowercased())@\(characteristic.service?.uuid.uuidString ?? "unknown")…")
            peripheral.readValue(for: characteristic)
            
            if(Volcano.subscribableIds.contains(characteristicId) ||
               Crafty.subscribableIds.contains(characteristicId)) {
                log.info("Activating notifications for \(characteristicId)@\(characteristic.service?.uuid.uuidString ?? "unknown")…")
                peripheral.setNotifyValue(true, for: characteristic)
            }
        } else {
            log.debug("Unknown characteristic: \(characteristicId)")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        let uuidString = characteristic.uuid.uuidString.lowercased()
        
        if let error = error {
            log.error("Error changing notification state for \(uuidString): \(error.localizedDescription)")
        } else {
            subscribedCharacteristics.append(uuidString)
            DispatchQueue.main.async {
                withAnimation {
                    self.objectWillChange.send()
                }
            }
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
    
    func setTemperature(_ temperature: Int) -> Bool {
        if (temperature > 0 && temperature <= 230) {
            return writeTemperature(temperature: temperature)
        } else {
            log.warning("Invalid temperature: \(temperature)°C")
            return false
        }
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
    
    func setLEDBrightness(_ newValue: Int) -> Bool {
        if let services = peripheral.services {
            let characteristics = services.flatMap({$0.characteristics ?? []})
            log.info("Writing LED Brightness \(newValue)…")
            withAnimation {
                writingValue = true
            }
            switch(deviceDetermination) {
            case .volcano:
                if let characteristic = characteristics.first(where: {$0.uuid == CBUUID(string: Volcano.ledBrightnessId)}) {
                    let data = withUnsafeBytes(of: UInt16(newValue).littleEndian) { Data($0) }
                    peripheral.writeValue(data, for: characteristic, type: .withResponse)
                    return true
                }
            case .crafty:
                log.warning("Device doesn't support LED brightness.")
            default:
                log.debug("Unknown device!")
            }
        }
        
        log.error("Unable to write LED brightness!")
        return false
    }
    
    func setAutoShutoffTime(_ newValue: Int) -> Bool {
        if let services = peripheral.services {
            let characteristics = services.flatMap({$0.characteristics ?? []})
            log.info("Writing auto shutoff time \(newValue)…")
            withAnimation {
                writingValue = true
            }
            switch(deviceDetermination) {
            case .volcano:
                if let characteristic = characteristics.first(where: {$0.uuid == CBUUID(string: Volcano.autoShutOffTimeId)}) {
                    let data = withUnsafeBytes(of: UInt16(newValue).littleEndian) { Data($0) }
                    peripheral.writeValue(data, for: characteristic, type: .withResponse)
                    return true
                }
            case .crafty:
                log.warning("Device doesn't support auto shutoff time.")
            default:
                log.debug("Unknown device!")
            }
        }
        
        log.error("Unable to write auto shutoff time!")
        return false
    }
}
