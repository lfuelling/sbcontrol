//
//  SBDevice.swift
//  sbcontrol
//
//  Created by Lukas Fülling on 6/12/24.
//

import Foundation

protocol SBDevice {
    static var compatibleIds: [String] { get }
    
    static func matchingName(_ name: String) -> Bool
    
    static var valueHandlers: [String: (_: Data, _: BLEManager) -> Void] { get }
    
    static var hasHeat: Bool { get }
    
    static var hasAir: Bool { get }
}
