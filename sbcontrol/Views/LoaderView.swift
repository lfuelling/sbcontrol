//
//  LoaderView.swift
//  sbcontrol
//
//  Created by Lukas Fülling on 6/15/24.
//

import SwiftUI

struct LoaderView: View {
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                VStack {
                    ProgressView().progressViewStyle(.circular)
                    Text("Initializing…")
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
