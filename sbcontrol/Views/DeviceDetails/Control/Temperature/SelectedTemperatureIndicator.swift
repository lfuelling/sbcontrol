//
//  SelectedTemperatureIndicator.swift
//  sbcontrol
//
//  Created by Lukas Fülling on 6/15/24.
//

import SwiftUI

struct SelectedTemperatureIndicator: View {
    @EnvironmentObject private var deviceState: DeviceState
    
    @State private var hovering = false
    @State private var sheetVisible = false
    
    var body: some View {
        VStack {
            Text("\(deviceState.selectedTemperature)°C")
                .font(.title)
        }
        .onTapGesture {
            sheetVisible = true
        }
#if !os(watchOS)
        .onHover { hovering in
            self.hovering = hovering
        }
#endif
        .sheet(isPresented: $sheetVisible) {
            TemperatureSelectionSheet()
            #if os(macOS)
                .padding()
                .frame(width: 250, height: 128)
            #endif
        }
#if os(macOS)
        .onChange(of: hovering) {
            DispatchQueue.main.async {
                if(hovering) {
                    NSCursor.pointingHand.push()
                } else {
                    NSCursor.pop()
                }
            }
        }
#endif
    }
}

#Preview {
    SelectedTemperatureIndicator()
}
