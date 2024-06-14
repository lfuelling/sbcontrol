//
//  DeviceDetermination.swift
//  sbcontrol
//
//  Created by Lukas Fülling on 6/14/24.
//

import Foundation

enum DeviceDetermination: String {
    case volcano, crafty, unknown
    
    var value: String {
        switch self {
        case .unknown:
            NSLocalizedString("device_type.unknown", comment: "unknown device type")
        case .crafty:
            NSLocalizedString("device_type.crafty", comment: "crafty device type")
        case .volcano:
            NSLocalizedString("device_type.volcano", comment: "volcano device type")
        }
    }
    
    var hasHeat: Bool {
        switch self {
        case .unknown:
            false
        case .crafty:
            Crafty.hasHeat
        case .volcano:
            Volcano.hasHeat
        }
    }
    
    var hasAir: Bool {
        switch self {
        case .unknown:
            false
        case .crafty:
            Crafty.hasAir
        case .volcano:
            Volcano.hasAir
        }
    }
}
