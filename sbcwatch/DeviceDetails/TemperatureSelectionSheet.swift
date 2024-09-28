//
//  TemperatureSelectionSheet.swift
//  sbcontrol
//
//  Created by Lukas Fülling on 28.09.24.
//  Copyright © 2024 Lerk Tech. All rights reserved.
//

import SwiftUI
import Combine

struct TemperatureSelectionSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject private var deviceState: DeviceState
    
    @State private var selectedTemperature: Double = 159
    
    @FocusState private var textFieldFocused: Bool
    
    fileprivate func setTemperature() {
        log.info("Settings temperature to \(selectedTemperature)°C…")
        let _ = deviceState.setTemperature(Int(selectedTemperature))
        dismiss()
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Stepper(value: $selectedTemperature,
                            in: (30.0...230.0),
                            step: 1.0,
                            format: .number) {
                        Text("\(selectedTemperature, specifier: "%.0f")°C")
                    }
                    .focused($textFieldFocused)
                    .onAppear {
                        self.selectedTemperature = Double(deviceState.selectedTemperature)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            withAnimation {
                                textFieldFocused = true
                            }
                        }
                    }
                } header: {
                    Text("Selected Temperature")
                }
                Button {
                    setTemperature()
                } label: {
                    Text("Set Temperature")
                }
            }
            .onSubmit {
                setTemperature()
            }
            .navigationTitle("Select Temperature")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
