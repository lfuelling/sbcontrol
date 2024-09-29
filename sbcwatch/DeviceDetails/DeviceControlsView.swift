//
//  TemperatureTabView.swift
//  sbcontrol
//
//  Created by Lukas Fülling on 28.09.24.
//  Copyright © 2024 Lerk Tech. All rights reserved.
//

import SwiftUI

struct DeviceControlsView: View {
    @EnvironmentObject private var metricsState: MetricsState
    @EnvironmentObject private var deviceState: DeviceState
    
    @State private var infoViewVisible: Bool = false
    @State private var temperatureSheetVisible: Bool = false
    
    var body: some View {
        VStack {
            Button {
                withAnimation {
                    temperatureSheetVisible = true
                }
            } label: {
                VStack {
                    DeviceControlsBatterySection()
                        .font(.footnote)
                    Text("Current: \(deviceState.currentTemperature)°C")
                        .bold()
                    Text("Selected: \(deviceState.selectedTemperature)°C")
                        .font(.footnote)
                }
            }.buttonStyle(.plain)
            GraphView(label: nil,
                      data: metricsState.graphSeries,
                      minValue: 0,
                      maxValue: 230,
                      xLabel: "Time",
                      yLabel: "Temperature (°C)").chartLegend(.hidden)
        }
        .navigationTitle(deviceState.deviceDetermination.value)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $infoViewVisible) {
            NavigationStack {
                DeviceInfoView()
            }
        }
        .sheet(isPresented: $temperatureSheetVisible) {
            NavigationStack {
                TemperatureSelectionSheet()
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    WKInterfaceDevice.current().play(.click)
                    let _ = deviceState.toggleAirPump()
                } label: {
                    Image(systemName: deviceState.airStatus ?
                          "humidifier.and.droplets.fill" : "humidifier.and.droplets")
                }
                .controlSize(.large)
                .disabled(!deviceState.deviceDetermination.hasAir || deviceState.writingValue)
                .foregroundStyle(deviceState.airStatus ? .blue : .primary)
                .shadow(color: deviceState.airStatus ? .blue : .clear, radius: 4, x: 0, y: 0)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    WKInterfaceDevice.current().play(.click)
                    let _ = deviceState.toggleHeat()
                } label: {
                    Image(systemName: deviceState.heatStatus ?
                          "thermometer.high" : "thermometer.medium.slash")
                }
                .controlSize(.large)
                .disabled(!deviceState.deviceDetermination.hasHeat || deviceState.writingValue)
                .foregroundStyle(deviceState.heatStatus ? .red : .primary)
                .shadow(color: deviceState.heatStatus ? .red : .clear, radius: 4, x: 0, y: 0)
            }
            ToolbarItemGroup(placement: .bottomBar) {
                Button {
                    WKInterfaceDevice.current().play(.click)
                    let _ = deviceState.setTemperature(deviceState.selectedTemperature - 5)
                } label: {
                    Text("-5")
                }
                .controlSize(.large)
                .disabled(deviceState.selectedTemperature <= 57 || deviceState.writingValue)
                
                Button {
                    withAnimation {
                        infoViewVisible = true
                    }
                } label: {
                    Image(systemName: "info")
                }
                
                Button {
                    WKInterfaceDevice.current().play(.click)
                    let _ = deviceState.setTemperature(deviceState.selectedTemperature + 5)
                } label: {
                    Text("+5")
                }
                .controlSize(.large)
                .disabled(deviceState.selectedTemperature >= 230 || deviceState.writingValue)
            }
        }
    }
}
