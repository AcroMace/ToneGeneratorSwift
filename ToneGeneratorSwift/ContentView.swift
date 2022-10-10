//
//  ContentView.swift
//  ToneGeneratorSwift
//
//  Created by Andy Cho on 10/10/22.
//

import SwiftUI

struct ContentView: View {

    let MinFrequency = 40.0
    let MaxFrequency = 4000.0

    @State private var frequency = 880.0
    @State private var isPlaying = false

    private let toneGenerator = ToneGenerator()

    init() {
        toneGenerator.frequency = frequency
    }

    var body: some View {
        VStack {
            Text(String(format: "Frequency: %.2f Hz", frequency))
                .frame(maxWidth: .infinity, alignment: .leading)

            Slider(
                value: $frequency,
                in: MinFrequency...MaxFrequency,
                onEditingChanged: { _ in
                    toneGenerator.frequency = frequency
                }
            )

            Button(isPlaying ? "Stop" : "Play") {
                isPlaying = !isPlaying
                if isPlaying {
                    toneGenerator.play()
                } else {
                    toneGenerator.stop()
                }
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
