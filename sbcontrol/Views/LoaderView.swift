//
//  LoaderView.swift
//  sbcontrol
//
//  Created by Lukas Fülling on 6/15/24.
//

import SwiftUI

struct LoaderView: View {
    @EnvironmentObject private var bleManager: BLEManager
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                VStack {
                    ProgressView().progressViewStyle(.circular)
                    
                    if (bleManager.deviceDetermination == .unknown) {
                        Text("Determining Device…")
                            .foregroundStyle(.secondary)
                            .padding(4)
                    } else {
                        let current = bleManager.subscribedCharacteristics.count + 1
                        let total: Int = switch(bleManager.deviceDetermination) {
                        case .unknown:
                            -1
                        case .crafty:
                            Crafty.subscribableIds.count
                        case .volcano:
                            Volcano.subscribableIds.count
                        }
                        Text("Loading data (\(current)/\(total))…")
                            .foregroundStyle(.secondary)
                            .padding(4)
                    }
                }
                Spacer()
            }
            Spacer()
        }
    }
}

#Preview {
    LoaderView()
}
