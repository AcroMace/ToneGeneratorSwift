//
//  ContentView.swift
//  ToneGeneratorSwift
//
//  Created by Andy Cho on 10/10/22.
//

import SwiftUI

struct ContentView: View {

    @State private var frequency = 880.0
    @State private var isEditing = false
    @State private var isPlaying = false

    var body: some View {
        VStack {
            Text(String(format: "Frequency: %.2f Hz", frequency))
                .frame(maxWidth: .infinity, alignment: .leading)

            Slider(
                value: $frequency,
                in: 40...4000,
                onEditingChanged: { editing in
                    isEditing = editing
                }
            )

            Button(isPlaying ? "Stop" : "Play") {
                isPlaying = !isPlaying
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
