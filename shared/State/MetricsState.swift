//
//  MetricsState.swift
//  sbcontrol
//
//  Created by Lukas Fülling on 7/1/24.
//

import SwiftUI
import Combine

class MetricsState: NSObject, ObservableObject {
    @AppStorage("graphMaxEntries") private var graphMaxEntries: Int = 500
    
    private var graphTimer: Timer?
    private var currentTemperatureGraphSeries: [GraphView.Datapoint] {
        didSet {
            if(currentTemperatureGraphSeries.count > graphMaxEntries) {
                currentTemperatureGraphSeries.remove(at: 0)
            }
        }
    }
    private var selectedTemperatureGraphSeries: [GraphView.Datapoint] {
        didSet {
            if(selectedTemperatureGraphSeries.count > graphMaxEntries) {
                selectedTemperatureGraphSeries.remove(at: 0)
            }
        }
    }
    private var airStatusGraphSeries: [GraphView.Datapoint] {
        didSet {
            if(airStatusGraphSeries.count > graphMaxEntries) {
                airStatusGraphSeries.remove(at: 0)
            }
        }
    }
    private var heaterStatusGraphSeries: [GraphView.Datapoint] {
        didSet {
            if(heaterStatusGraphSeries.count > graphMaxEntries) {
                heaterStatusGraphSeries.remove(at: 0)
            }
        }
    }
    var graphSeries: [GraphView.DataSeries] {
        let currentTemperatureSeries = GraphView.DataSeries(label: "Current Temperature (°C)",
                                                            data: self.currentTemperatureGraphSeries,
                                                            booleanValue: false,
                                                            color: Color.red,
                                                            symbol: .circle)
        let selectedTemperatureSeries = GraphView.DataSeries(label: "Selected Temperature (°C)",
                                                             data: self.selectedTemperatureGraphSeries,
                                                             booleanValue: false,
                                                             color: Color.green,
                                                             symbol: .diamond)
        let airStatusSeries = GraphView.DataSeries(label: "Air Pump",
                                                   data: self.airStatusGraphSeries,
                                                   booleanValue: true,
                                                   color: .blue,
                                                   symbol: .triangle)
        let heaterStatusSeries = GraphView.DataSeries(label: "Heater",
                                                      data: self.heaterStatusGraphSeries,
                                                      booleanValue: true,
                                                      color: .red,
                                                      symbol: .plus)
        return [currentTemperatureSeries, selectedTemperatureSeries, airStatusSeries, heaterStatusSeries]
    }
    
    override init() {
        log.debug("Initializing…")
        currentTemperatureGraphSeries = []
        selectedTemperatureGraphSeries = []
        airStatusGraphSeries = []
        heaterStatusGraphSeries = []
        
        super.init()
        
        for i in 0...graphMaxEntries {
            let entryTimestamp = Date().timeIntervalSince1970 - Double(graphMaxEntries-i)
            currentTemperatureGraphSeries.append(GraphView.Datapoint(time: entryTimestamp, value: 0))
            selectedTemperatureGraphSeries.append(GraphView.Datapoint(time: entryTimestamp, value: 0))
            airStatusGraphSeries.append(GraphView.Datapoint(time: entryTimestamp, value: 0))
            heaterStatusGraphSeries.append(GraphView.Datapoint(time: entryTimestamp, value: 0))
        }
        
        DispatchQueue.main.async {
            withAnimation {
                self.objectWillChange.send()
            }
        }
    }
    
    func resetState() {
        log.info("Resetting State…")
        
        var newCurrentTemperatureGraphSeries: [GraphView.Datapoint] = []
        var newSelectedTemperatureGraphSeries: [GraphView.Datapoint] = []
        var newAirStatusGraphSeries: [GraphView.Datapoint] = []
        var newHeaterStatusGraphSeries: [GraphView.Datapoint] = []
        
        for i in 0...graphMaxEntries {
            let entryTimestamp = Date().timeIntervalSince1970 - Double(graphMaxEntries-i)
            newCurrentTemperatureGraphSeries.append(GraphView.Datapoint(time: entryTimestamp, value: 0))
            newSelectedTemperatureGraphSeries.append(GraphView.Datapoint(time: entryTimestamp, value: 0))
            newAirStatusGraphSeries.append(GraphView.Datapoint(time: entryTimestamp, value: 0))
            newHeaterStatusGraphSeries.append(GraphView.Datapoint(time: entryTimestamp, value: 0))
        }
        
        withAnimation {
            currentTemperatureGraphSeries = newCurrentTemperatureGraphSeries
            selectedTemperatureGraphSeries = newSelectedTemperatureGraphSeries
            airStatusGraphSeries = newAirStatusGraphSeries
            heaterStatusGraphSeries = newHeaterStatusGraphSeries
        }
        
        DispatchQueue.main.async {
            withAnimation {
                self.objectWillChange.send()
            }
        }
    }
    
    func createTimer(deviceState: DeviceState) {
        log.debug("Creating timer…")
        self.graphTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.createGraphEntry(currentTemperature: deviceState.currentTemperature,
                                  selectedTemperature: deviceState.selectedTemperature,
                                  airStatus: deviceState.airStatus,
                                  heatStatus: deviceState.heatStatus)
        }
    }
    
    func cancelTimer() {
        log.debug("Cancelling timer…")
        self.graphTimer?.invalidate()
        self.graphTimer = nil
    }
    
    fileprivate func createGraphEntry(currentTemperature: Int, selectedTemperature: Int, airStatus: Bool, heatStatus: Bool) {
        let entryDate = Date.now.timeIntervalSince1970
        self.currentTemperatureGraphSeries.append(GraphView.Datapoint(time: entryDate,
                                                                      value: Double(currentTemperature)))
        self.selectedTemperatureGraphSeries.append(GraphView.Datapoint(time: entryDate,
                                                                       value: Double(selectedTemperature)))
        self.airStatusGraphSeries.append(GraphView.Datapoint(time: entryDate,
                                                             value: airStatus ? 1 : 0))
        self.heaterStatusGraphSeries.append(GraphView.Datapoint(time: entryDate,
                                                                value: heatStatus ? 1 : 0))
   
        DispatchQueue.main.async {
            withAnimation {
                self.objectWillChange.send()
            }
        }
    }
}
