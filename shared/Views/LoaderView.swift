//
//  LoaderView.swift
//  sbcontrol
//
//  Created by Lukas Fülling on 6/15/24.
//

import SwiftUI

struct LoaderView: View {
    @EnvironmentObject private var deviceState: DeviceState
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                VStack {
                    ProgressView().progressViewStyle(.circular)
                    
                    if (deviceState.deviceDetermination == .unknown) {
                        Text("Determining Device…")
                            .foregroundStyle(.secondary)
                            .padding(4)
                    } else {
                        let current = deviceState.subscribedCharacteristics.count + 1
                        let total: Int = switch(deviceState.deviceDetermination) {
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
        }.navigationTitle(Text("Connecting…"))
    }
}

#Preview {
    LoaderView()
}
