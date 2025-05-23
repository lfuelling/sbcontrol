//
//  Volcano.swift
//  sbcontrol
//
//  Created by Lukas Fülling on 6/12/24.
//

import Foundation

class Volcano: SBDevice {
    static let hasHeat: Bool = true
    static let hasAir: Bool = true
    static let hasBattery: Bool = false
    static let hasScreen: Bool = true
    static let hasAutoshutoffTime: Bool = true
    
    static let currentTempId = "10110001-5354-4f52-5a26-4249434b454c" // Current temperature
    static let selectedTempId = "10110003-5354-4f52-5a26-4249434b454c" // Set temperature
    static let stat1Id = "1010000c-5354-4f52-5a26-4249434b454c" // stat1 (airpump/heater status)
    static let autoShutoffId = "1011000c-5354-4f52-5a26-4249434b454c" // auto shut off enabled
    static let autoShutOffTimeId = "1011000d-5354-4f52-5a26-4249434b454c" // auto shut off time
    static let operationHoursId = "10110015-5354-4f52-5a26-4249434b454c" // operation hours
    static let ledBrightnessId = "10110005-5354-4f52-5a26-4249434b454c" // led brightness
    static let serialNumberId = "10100008-5354-4f52-5a26-4249434b454c" // serial number
    static let firmwareVersionId = "10100003-5354-4f52-5a26-4249434b454c" // firmware version
    static let bleFirmwareVersionId = "10100004-5354-4f52-5a26-4249434b454c" // ble firmware version
    static let stat2Id = "1010000d-5354-4f52-5a26-4249434b454c" // stat2 (fahrenheit enabled 0x200, display on cooling 0x1000)
    static let stat3Id = "1010000e-5354-4f52-5a26-4249434b454c" // stat3 (vibration enabled 0x400)
    static let heatOnId = "1011000f-5354-4f52-5a26-4249434b454c" // heat ON
    static let heatOffId = "10110010-5354-4f52-5a26-4249434b454c" // heat OFF
    static let airOnId = "10110013-5354-4f52-5a26-4249434b454c" // air ON
    static let airOffId = "10110014-5354-4f52-5a26-4249434b454c" // air OFF
    
    static let compatibleIds = [currentTempId,
                                selectedTempId,
                                stat1Id,
                                autoShutoffId,
                                autoShutOffTimeId,
                                operationHoursId,
                                ledBrightnessId,
                                serialNumberId,
                                firmwareVersionId,
                                bleFirmwareVersionId,
                                stat2Id,
                                stat3Id,
                                heatOnId,
                                heatOffId,
                                airOnId,
                                airOffId]
    
    static let subscribableIds: [String] = [currentTempId,
                                            selectedTempId,
                                            stat1Id,
                                            autoShutoffId,
                                            operationHoursId,
                                            stat2Id,
                                            stat3Id]
    
    static func matchingName(_ name: String) -> Bool {
        return name.starts(with: "S&B")
    }
    
    static let valueHandlers: [String: (_: Data, _: DeviceState) -> Void] = [
        currentTempId: {data, deviceState in
            let intValue = UInt32(littleEndian: data.withUnsafeBytes { $0.load(as: UInt32.self) })
            let currentTemperature = Int(intValue / 10)
            log.info("Received current temperature: \(currentTemperature)°C")
            deviceState.currentTemperature = currentTemperature
        },
        selectedTempId: {data, deviceState in
            let intValue = UInt32(littleEndian: data.withUnsafeBytes { $0.load(as: UInt32.self) })
            let selectedTemperature = Int(intValue / 10)
            log.info("Received selected temperature: \(selectedTemperature)°C")
            deviceState.selectedTemperature = selectedTemperature
        },
        stat1Id: {data, deviceState in
            let heaterValue = Int(data[0])
            let heaterStatus = (heaterValue & 0x0020) != 0
            log.info("Received heater status: \(heaterStatus)")
            deviceState.heatStatus = heaterStatus
            
            let airValue = Int(data[1])
            let airPumpStatus = (airValue & 0x0030) != 0
            log.info("Received air pump status: \(heaterStatus)")
            deviceState.airStatus = airPumpStatus
        },
        autoShutoffId: {data, deviceState in
            let intValue = UInt8(littleEndian: data.withUnsafeBytes { $0.load(as: UInt8.self) })
            log.info("Received auto shut off enabled: \(intValue)")
        },
        autoShutOffTimeId: {data, deviceState in
            let intValue = UInt16(littleEndian: data.withUnsafeBytes { $0.load(as: UInt16.self) })
            log.info("Received autoShutOffTime: \(intValue)")
            deviceState.deviceAutoShutoffTime = Int(intValue)
        },
        operationHoursId: {data, deviceState in
            let intValue = UInt32(littleEndian: data.withUnsafeBytes { $0.load(as: UInt32.self) })
            log.info("Received operationHours: \(intValue)")
            deviceState.hoursOfOperation = Int(intValue)
        },
        ledBrightnessId: {data, deviceState in
            let intValue = UInt16(littleEndian: data.withUnsafeBytes { $0.load(as: UInt16.self) })
            log.info("Received ledBrightness: \(intValue)")
            deviceState.deviceLEDBrightness = Int(intValue)
        },
        serialNumberId: {data, deviceState in
            let intValue = UInt32(littleEndian: data.withUnsafeBytes { $0.load(as: UInt32.self) })
            log.info("Received serialNumber: \(intValue)")
            deviceState.serialNumber = "\(intValue)"
        },
        firmwareVersionId: {data, deviceState in
            let intValue = UInt32(littleEndian: data.withUnsafeBytes { $0.load(as: UInt32.self) })
            if let versionString = String(data: data, encoding: .utf8) {
                log.info("Received firmwareVersion: \(versionString) (\(intValue))")
                deviceState.deviceFirmwareVersion = versionString
            } else {
                log.error("Unable to get version string!")
            }
        },
        bleFirmwareVersionId: {data, deviceState in
            let intValue = UInt32(littleEndian: data.withUnsafeBytes { $0.load(as: UInt32.self) })
            if let versionString = String(data: data, encoding: .utf8) {
                log.info("Received bleFirmwareVersion: \(versionString) (\(intValue))")
                deviceState.deviceBLEFirmwareVersion = versionString
            } else {
                log.error("Unable to get BLW version string!")
            }
        },
        stat2Id: {data, deviceState in
            let intValue = UInt32(littleEndian: data.withUnsafeBytes { $0.load(as: UInt32.self) })
            log.info("Received stat2: \(intValue)")
        },
        stat3Id: {data, deviceState in
            let intValue = UInt32(littleEndian: data.withUnsafeBytes { $0.load(as: UInt32.self) })
            log.info("Received stat3: \(intValue)")
        }
    ]
}
