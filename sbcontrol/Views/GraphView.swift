//
//  GraphView.swift
//  sbcontrol
//
//  Created by Lukas Fülling on 09/05/2024.
//

import SwiftUI
import Charts

struct GraphView: View {
    
    struct Datapoint: Identifiable {
        let time: Double
        let value: Double
        
        var id: Double {
            return time
        }
    }
    
    struct DataSeries: Identifiable {
        var label: String
        var data: [Datapoint]
        var color: Color
        
        let booleanValue: Bool
        
        var id: String {
            return label
        }
        
        init(label: String, data: [Datapoint]) {
            self.init(label: label,
                      data: data,
                      booleanValue: false,
                      color: Color.accentColor)
        }
        
        init(label: String, data: [Datapoint], booleanValue: Bool, color: Color) {
            self.label = label
            self.data = data
            self.booleanValue = booleanValue
            self.color = color
        }
    }
    
    var label: String
    var data: [DataSeries]
    var minValue: Double = 0
    var maxValue: Double = 100
    var xLabel: String = NSLocalizedString("graph_view.generic.x_label", comment: "graph view generic x axis label")
    var yLabel: String = NSLocalizedString("graph_view.generic.y_label", comment: "graph view generic y axis label")
    
    var minTime: Double {
        return data.flatMap { $0.data.map { $0.time } }.min() ?? 0
    }
    
    var maxTime: Double {
        return data.flatMap { $0.data.map { $0.time } }.max() ?? 0
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(label)
                .font(.title2)
                .padding(.bottom)
            Chart(data) { dataSeries in
                if(dataSeries.booleanValue) {
                    ForEach(dataSeries.data) { data in
                        if(data.value == 1) {
                            RectangleMark(
                                xStart: .value(xLabel, Date(timeIntervalSince1970: data.time - 0.5)),
                                xEnd: .value(xLabel, Date(timeIntervalSince1970: data.time + 0.5))
                            )
                            .foregroundStyle(dataSeries.color.opacity(0.3))
                        }
                    }
                } else {
                    ForEach(dataSeries.data) { data in
                        LineMark(x: .value(xLabel, Date(timeIntervalSince1970: data.time)),
                                 y: .value(yLabel, data.value))
                    }
                    .foregroundStyle(by: .value(label, dataSeries.label))
                    //.symbol(by: .value(label, dataSeries.label))
                }
            }
            .chartYScale(domain: minValue...maxValue)
            .chartXScale(domain: Date(timeIntervalSince1970: minTime)...Date(timeIntervalSince1970: maxTime))
            .scrollDisabled(true)
            .padding(2)
        }.padding()
    }
}

#Preview {
    GraphView(label: "Tests",
              data: [GraphView.DataSeries(label: "test",
                                          data: [GraphView.Datapoint(time: 0, value: 0),
                                                 GraphView.Datapoint(time: 1, value: 10),
                                                 GraphView.Datapoint(time: 2, value: 100),
                                                 GraphView.Datapoint(time: 5, value: 90),
                                                 GraphView.Datapoint(time: 10, value: 20),
                                                 GraphView.Datapoint(time: 12, value: 10)]),
                     GraphView.DataSeries(label: "test2",
                                          data: [GraphView.Datapoint(time: 0, value: 10),
                                                 GraphView.Datapoint(time: 1, value: 20),
                                                 GraphView.Datapoint(time: 2, value: 10),
                                                 GraphView.Datapoint(time: 5, value: 0),
                                                 GraphView.Datapoint(time: 10, value: 22),
                                                 GraphView.Datapoint(time: 12, value: 10)])])
}
