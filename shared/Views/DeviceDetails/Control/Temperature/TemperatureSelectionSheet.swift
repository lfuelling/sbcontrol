//
//  TemperatureSelectionSheet.swift
//  sbcontrol
//
//  Created by Lukas Fülling on 6/15/24.
//

import SwiftUI
import Combine

struct TemperatureSelectionSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject private var deviceState: DeviceState
    
    @State private var selectedTemperature = "159"
    
    @FocusState private var textFieldFocused: Bool
    
    fileprivate func setTemperature() {
        log.info("Settings temperature to \(selectedTemperature)°C…")
        let temperatureToSet = Int(selectedTemperature) ?? deviceState.currentTemperature
        let _ = deviceState.setTemperature(temperatureToSet)
        dismiss()
    }
    
    var body: some View {
        NavigationStack {
            Form {
#if os(macOS)
                Spacer()
#endif
                Section {
                    TextField("Selected Temperature", text: $selectedTemperature)
#if os(iOS)
                        .keyboardType(.numberPad)
                        .submitLabel(.done)
#endif
                        .labelsHidden()
                        .focused($textFieldFocused)
                        .onReceive(Just(selectedTemperature)) { newValue in
                            let filtered = newValue.filter { "0123456789".contains($0) }
                            let intValue = Int(newValue) ?? -1
                            if filtered != newValue &&
                                (intValue > 0 && intValue <= 230) {
                                self.selectedTemperature = filtered
                            }
                        }
                        .onAppear {
                            self.selectedTemperature = "\(deviceState.selectedTemperature)"
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                withAnimation {
                                    textFieldFocused = true
                                }
                            }
                        }
                } header: {
                    Text("Selected Temperature")
                }
#if os(macOS)
                Spacer()
#endif
            }
            .onSubmit {
                setTemperature()
            }
#if os(iOS)
            .navigationTitle("Select Temperature")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        setTemperature()
                    } label: {
                        Text("Done")
                    }
                }
            }
#endif
#if os(macOS)
            Divider()
            HStack {
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                }
                Spacer()
                Button {
                    setTemperature()
                } label: {
                    Text("Done")
                }
            }
#endif
        }
    }
}

#Preview {
    TemperatureSelectionSheet()
}
