//
//  SBDevice.swift
//  sbcontrol
//
//  Created by Lukas Fülling on 6/12/24.
//

import Foundation

protocol SBDevice {
    static var compatibleIds: [String] { get }
    
    static var subscribableIds: [String] { get }
    
    static func matchingName(_ name: String) -> Bool
    
    static var valueHandlers: [String: (_: Data, _: DeviceState) -> Void] { get }
    
    static var hasHeat: Bool { get }
    static var hasAir: Bool { get }
    static var hasBattery: Bool { get }
    static var hasScreen: Bool { get }
    static var hasAutoshutoffTime: Bool { get }
}
