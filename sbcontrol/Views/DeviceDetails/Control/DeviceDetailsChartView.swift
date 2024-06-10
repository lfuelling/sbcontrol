//
//  DeviceControlChartView.swift
//  sbcontrol
//
//  Created by Lukas Fülling on 6/10/24.
//

import SwiftUI
import Charts

struct DeviceControlChartView: View {
    @EnvironmentObject private var bleManager: BLEManager
    
    var body: some View {
        GraphView(label: "Temperatures", 
                  data: bleManager.graphSeries,
                  minValue: 0,
                  maxValue: 230,
                  xLabel: "Time",
                  yLabel: "Temperature (°C)")
    }
}

#Preview {
    DeviceControlChartView()
}
