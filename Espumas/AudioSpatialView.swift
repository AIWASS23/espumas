//
//  AudioSpatialView.swift
//  Espumas
//
//  Created by marcelodearaujo on 11/27/24.
//

import SwiftUI
import AVFAudio

// Testes para ouvir 

struct AudioSpatialView: View {
    var body: some View {
        VStack(spacing: 20) {
            Button(action: {
                AudioManager.shared.playSound(named: "bubble", at: AVAudio3DPoint(x: 5.0, y: 0.0, z: -5.0))
            }) {
                Text("Play Sound from Front-Right")
            }
            
            Button(action: {
                AudioManager.shared.playSound(named: "bubble", at: AVAudio3DPoint(x: -5.0, y: 0.0, z: -5.0))
            }) {
                Text("Play Sound from Front-Left")
            }
            
            Button(action: {
                AudioManager.shared.playSound(named: "bubble", at: AVAudio3DPoint(x: 0.0, y: 5.0, z: 0.0))
            }) {
                Text("Play Sound from Above")
            }
            
            Button(action: {
                AudioManager.shared.playSound(named: "bubble", at: AVAudio3DPoint(x: 0.0, y: -5.0, z: 0.0))
            }) {
                Text("Play Sound from Below")
            }
            
            
            Button(action: {
                AudioManager.shared.playAmbientSound(named: "bubble")
            }) {
                Text("Play Ambient Sound")
            }
            
            Button(action: {
                AudioManager.shared.playDirectionalCue(named: "bubble", from: AVAudio3DPoint(x: 3.0, y: 0.0, z: -3.0))
            }) {
                Text("Play Directional Cue")
            }
            
            Button(action: {
                AudioManager.shared.setOcclusionAndObstruction(occlusion: 0.3, obstruction: 0.5)
            }) {
                Text("Set Occlusion and Obstruction")
            }
        }
        .padding()
    }
}

#Preview {
    AudioSpatialView()
}
