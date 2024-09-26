//
//  Crafty.swift
//  sbcontrol
//
//  Created by Lukas Fülling on 6/12/24.
//

import Foundation

class Crafty: SBDevice {
    static let hasHeat: Bool = true
    static let hasAir: Bool = false
    static let hasBattery: Bool = true
    static let hasScreen: Bool = false
    static let hasAutoshutoffTime: Bool = false

    static let currentTempId = "00000011-4c45-4b43-4942-265a524f5453"
    static let selectedTempId = "00000021-4c45-4b43-4942-265a524f5453"
    static let boostId = "00000031-4c45-4b43-4942-265a524f5453"
    static let batteryId = "00000041-4c45-4b43-4942-265a524f5453"
    static let ledId = "00000051-4c45-4b43-4942-265a524f5453"
    static let metaDataId = "00000002-4c45-4b43-4942-265a524f5453"
    static let modelId = "00000022-4c45-4b43-4942-265a524f5453"
    static let versionId = "00000032-4c45-4b43-4942-265a524f5453"
    static let serialId = "00000052-4c45-4b43-4942-265a524f5453"
    static let miscDataId = "00000003-4c45-4b43-4942-265a524f5453"
    static let hoursOfOperationId = "00000023-4c45-4b43-4942-265a524f5453"
    static let settingsId = "000001c3-4c45-4b43-4942-265a524f5453"
    static let powerId = "00000063-4c45-4b43-4942-265a524f5453"
    static let chargingId = "000000a3-4c45-4b43-4942-265a524f5453"
    static let powerBoostHeatStateId = "00000093-4c45-4b43-4942-265a524f5453"
    static let batRemainingId = "00000153-4c45-4b43-4942-265a524f5453"
    static let batTotalId = "00000143-4c45-4b43-4942-265a524f5453"
    static let batDesignId = "00000183-4c45-4b43-4942-265a524f5453"
    static let batDischargeCyclesId = "00000163-4c45-4b43-4942-265a524f5453"
    static let batChargeCyclesId = "00000173-4c45-4b43-4942-265a524f5453"
    
    static let heaterOnId = "00000081-4c45-4b43-4942-265a524f5453"
    static let heaterOffId = "00000091-4c45-4b43-4942-265a524f5453"
    
    static var compatibleIds: [String] = [
        currentTempId,
        selectedTempId,
        boostId,
        batteryId,
        ledId,
        metaDataId,
        modelId,
        versionId,
        serialId,
        miscDataId,
        hoursOfOperationId,
        settingsId,
        powerId,
        chargingId,
        powerBoostHeatStateId,
        batRemainingId,
        batTotalId,
        batDesignId,
        batDischargeCyclesId,
        batChargeCyclesId,
        heaterOnId,
        heaterOffId
    ]
    
    static var subscribableIds: [String] = [
        currentTempId,
        batteryId,
        hoursOfOperationId,
        settingsId,
        powerId,
        powerBoostHeatStateId
    ]
    
    static func matchingName(_ name: String) -> Bool {
        return name.starts(with: "STORZ&BICKEL") || name.starts(with: "Storz&Bickel")
    }
    
    static var valueHandlers: [String : (Data, DeviceState) -> Void] = [
        currentTempId: { data, deviceState in
            let intValue = UInt16(littleEndian: data.withUnsafeBytes { $0.load(as: UInt16.self) })
            let currentTemperature = Int(intValue / 10)
            log.info("Received current temperature: \(currentTemperature)°C")
            deviceState.currentTemperature = currentTemperature
        },
        selectedTempId: { data, deviceState in
            let intValue = UInt16(littleEndian: data.withUnsafeBytes { $0.load(as: UInt16.self) })
            let selectedTemperature = Int(intValue / 10)
            log.info("Received selected temperature: \(selectedTemperature)°C")
            deviceState.selectedTemperature = selectedTemperature
        },
        boostId: { data, deviceState in
            let intValue = UInt16(littleEndian: data.withUnsafeBytes { $0.load(as: UInt16.self) })
            log.info("Received boostId: \(intValue)")
        },
        batteryId: { data, deviceState in
            let intValue = UInt16(littleEndian: data.withUnsafeBytes { $0.load(as: UInt16.self) })
            log.info("Received batteryId: \(intValue)")
            deviceState.batteryPercent = Int(intValue)
        },
        ledId: { data, deviceState in
            let intValue = UInt16(littleEndian: data.withUnsafeBytes { $0.load(as: UInt16.self) })
            log.info("Received ledId: \(intValue)")
        },
        metaDataId: { data, deviceState in
            let intValue = UInt32(littleEndian: data.withUnsafeBytes { $0.load(as: UInt32.self) })
            log.info("Received metaDataId: \(intValue)")
        },
        modelId: { data, deviceState in
            let intValue = UInt32(littleEndian: data.withUnsafeBytes { $0.load(as: UInt32.self) })
            log.info("Received modelId: \(intValue)")
        },
        versionId: { data, deviceState in
            let intValue = UInt32(littleEndian: data.withUnsafeBytes { $0.load(as: UInt32.self) })
            log.info("Received versionId: \(intValue)")
        },
        serialId: { data, deviceState in
            let intValue = UInt32(littleEndian: data.withUnsafeBytes { $0.load(as: UInt32.self) })
            log.info("Received serialId: \(intValue)")
            deviceState.serialNumber = "\(intValue)"
        },
        miscDataId: { data, deviceState in
            let intValue = UInt32(littleEndian: data.withUnsafeBytes { $0.load(as: UInt32.self) })
            log.info("Received miscDataId: \(intValue)")
        },
        hoursOfOperationId: { data, deviceState in
            let intValue = UInt16(littleEndian: data.withUnsafeBytes { $0.load(as: UInt16.self) })
            log.info("Received hoursOfOperationId: \(intValue)")
            deviceState.hoursOfOperation = Int(intValue)
        },
        settingsId: { data, deviceState in
            let intValue = UInt16(littleEndian: data.withUnsafeBytes { $0.load(as: UInt16.self) })
            log.info("Received settingsId: \(intValue)")
        },
        powerId: { data, deviceState in
            let intValue = UInt16(littleEndian: data.withUnsafeBytes { $0.load(as: UInt16.self) })
            log.info("Received powerId: \(intValue)")
            if(intValue == 32916) {
                deviceState.powerState = true
            } else if(intValue == 16) {
                deviceState.powerState = false
            }
        },
        chargingId: { data, deviceState in
            let intValue = UInt16(littleEndian: data.withUnsafeBytes { $0.load(as: UInt16.self) })
            log.info("Received chargingId: \(intValue)")
            deviceState.powerState = intValue == 2
        },
        powerBoostHeatStateId: { data, deviceState in
            let intValue = UInt16(littleEndian: data.withUnsafeBytes { $0.load(as: UInt16.self) })
            log.info("Received powerBoostHeatStateId: \(intValue)")
            let powerState = (Int(data[0]) & 0x10) == 0x10
            let heatingState = (Int(data[0]) & 0x5) == 0x5
            let boostState = (Int(data[0]) & 0x20) == 0x20
            
            deviceState.heatStatus = heatingState
            log.debug("Decoded heater status: \(heatingState)")
            log.debug("Decoded power status: \(powerState)")
            log.debug("Decoded boost status: \(boostState)")
        },
        batRemainingId: { data, deviceState in
            let intValue = UInt16(littleEndian: data.withUnsafeBytes { $0.load(as: UInt16.self) })
            log.info("Received batRemainingId: \(intValue)")
        },
        batTotalId: { data, deviceState in
            let intValue = UInt16(littleEndian: data.withUnsafeBytes { $0.load(as: UInt16.self) })
            log.info("Received batTotalId: \(intValue)")
        },
        batDesignId: { data, deviceState in
            let intValue = UInt16(littleEndian: data.withUnsafeBytes { $0.load(as: UInt16.self) })
            log.info("Received batDesignId: \(intValue)")
        },
        batDischargeCyclesId: { data, deviceState in
            let intValue = UInt16(littleEndian: data.withUnsafeBytes { $0.load(as: UInt16.self) })
            log.info("Received batDischargeCyclesId: \(intValue)")
        },
        batChargeCyclesId: { data, deviceState in
            let intValue = UInt16(littleEndian: data.withUnsafeBytes { $0.load(as: UInt16.self) })
            log.info("Received batChargeCyclesId: \(intValue)")
        }
    ]
}
